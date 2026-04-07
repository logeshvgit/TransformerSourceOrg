import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_TIER from '@salesforce/schema/Account.Account_Size_Tier__c';
import ACCOUNT_STATUS from '@salesforce/schema/Account.Account_Customer_Status__c';
import ACCOUNT_LAST_SERVICE from '@salesforce/schema/Account.Last_Service_Date__c';
import ACCOUNT_CLOSED_CASES from '@salesforce/schema/Account.Closed_Support_Cases__c';
import ACCOUNT_CSM from '@salesforce/schema/Account.CSM__c';
import USER_NAME from '@salesforce/schema/User.Name';

const ACCOUNT_FIELDS = [
    ACCOUNT_NAME,
    ACCOUNT_TIER,
    ACCOUNT_STATUS,
    ACCOUNT_LAST_SERVICE,
    ACCOUNT_CLOSED_CASES,
    ACCOUNT_CSM
];

const USER_FIELDS = [USER_NAME];

function computeExpectedPriority(tier, status) {
    if (status === 'Churning') {
        return { value: 'High', reason: 'Customer status is Churning.' };
    }
    if (tier === 'Enterprise' && status === 'At_Risk') {
        return { value: 'High', reason: 'Enterprise account with At Risk status.' };
    }
    if (tier === 'SMB') {
        return { value: 'Low', reason: 'SMB tier defaults to Low priority.' };
    }
    return { value: 'Medium', reason: 'Default routing tier for new cases.' };
}

export default class PrintCoAccountHealth extends NavigationMixin(LightningElement) {
    @api recordId;

    loading = true;
    error;
    _data;
    _csmName;

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this._data = data;
            this.error = undefined;
            this.loading = false;
        } else if (error) {
            this.error = error;
            this._data = undefined;
            this.loading = false;
        } else {
            this.loading = true;
        }
    }

    @wire(getRecord, { recordId: '$csmId', fields: USER_FIELDS })
    wiredCsmUser({ data }) {
        this._csmName = data ? getFieldValue(data, USER_NAME) : undefined;
    }

    get hasData() {
        return this._data;
    }

    get accountName() {
        return getFieldValue(this._data, ACCOUNT_NAME);
    }

    get tier() {
        return getFieldValue(this._data, ACCOUNT_TIER);
    }

    get customerStatus() {
        return getFieldValue(this._data, ACCOUNT_STATUS);
    }

    get lastServiceDate() {
        const d = getFieldValue(this._data, ACCOUNT_LAST_SERVICE);
        if (!d) {
            return null;
        }
        try {
            return new Intl.DateTimeFormat(undefined, {
                dateStyle: 'medium'
            }).format(new Date(d));
        } catch (e) {
            return d;
        }
    }

    get closedCases() {
        const n = getFieldValue(this._data, ACCOUNT_CLOSED_CASES);
        return n != null ? n : 0;
    }

    get csmId() {
        return this._data ? getFieldValue(this._data, ACCOUNT_CSM) : undefined;
    }

    get csmName() {
        return this._csmName;
    }

    get priorityPreview() {
        return computeExpectedPriority(this.tier, this.customerStatus);
    }

    get tierLabel() {
        return this.formatPicklist(this.tier);
    }

    get statusLabel() {
        return this.formatPicklist(this.customerStatus);
    }

    formatPicklist(raw) {
        if (raw == null || raw === '') {
            return '—';
        }
        return String(raw).replace(/_/g, ' ');
    }

    handleOpenCsm(event) {
        event.preventDefault();
        if (!this.csmId) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.csmId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });
    }
}
