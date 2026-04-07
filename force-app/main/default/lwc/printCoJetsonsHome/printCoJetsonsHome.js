import { LightningElement } from 'lwc';

const PRODUCTS = [
    { id: 1, name: 'PrintCo Press 5000', sku: 'PC-PRESS-5000', family: 'Hardware', price: '$124,500', badge: 'FLAGSHIP', desc: 'Production-class digital press — 100+ ppm, duplex, inline finishing.' },
    { id: 2, name: 'Wide Format 36"', sku: 'PC-WIDE-36', family: 'Hardware', price: '$18,900', badge: 'POPULAR', desc: 'Large-format inkjet for blueprints, posters & signage up to 36 in.' },
    { id: 3, name: 'Color Production A3', sku: 'PC-COLOR-A3', family: 'Hardware', price: '$34,200', badge: '', desc: 'A3 color laser with Fiery-ready controller and 80-ppm engine.' },
    { id: 4, name: 'Mono Fleet A4', sku: 'PC-MONO-A4', family: 'Hardware', price: '$4,750', badge: '', desc: 'High-volume A4 mono laser — 65 ppm, 250K duty cycle.' },
    { id: 5, name: 'Fiery RIP Module', sku: 'PC-FIERY-RIP', family: 'Software', price: '$8,600', badge: 'SOFTWARE', desc: 'ICC-profile color management & soft-proof RIP controller.' },
    { id: 6, name: 'Toner Set CMYK', sku: 'PC-TONER-CMYK', family: 'Supplies', price: '$320', badge: '', desc: 'Full CMYK toner cartridge set — yields 30K pages at 5% coverage.' },
    { id: 7, name: 'Booklet Finisher Pro', sku: 'PC-FINISH-BOOK', family: 'Supplies', price: '$6,100', badge: '', desc: 'Saddle-stitch booklet maker with tri-fold, up to 20-sheet booklets.' },
    { id: 8, name: 'Fuser Maintenance Kit', sku: 'PC-FUSER-KIT', family: 'Supplies', price: '$475', badge: '', desc: 'Replacement fuser unit — rated for 200K impressions.' },
    { id: 9, name: 'Gloss Media Roll', sku: 'PC-MEDIA-GLOSS', family: 'Supplies', price: '$89', badge: '', desc: '36 in × 100 ft gloss-coated roll for wide-format photo output.' },
    { id: 10, name: 'Gold SLA Add-on', sku: 'PC-SLA-GOLD', family: 'Services', price: '$2,400/yr', badge: 'PREMIUM', desc: '4-hour on-site response, 24/7 remote diagnostics, priority parts.' }
];

const ARTICLES = [
    { id: 1, icon: '📄', title: 'How to clear a paper jam on the PrintCo Press 5000', summary: 'Step-by-step guide to safely clear paper jams on production press models.' },
    { id: 2, icon: '🖨️', title: 'Replacing toner cartridges on PrintCo color devices', summary: 'Instructions for replacing CMYK toner cartridges across PrintCo color models.' },
    { id: 3, icon: '🎨', title: 'Configuring the Fiery RIP Module for color-accurate proofing', summary: 'Set up the Fiery RIP for ICC-profile-based color matching and soft proofing.' },
    { id: 4, icon: '⭐', title: 'PrintCo Gold SLA — coverage and response times', summary: 'Overview of coverage, response times, and included services under the Gold SLA add-on.' }
];

export default class PrintCoJetsonsHome extends LightningElement {
    products = PRODUCTS;
    articles = ARTICLES;
    orgId = '00DgL00000N396L';
    returnUrl = 'https://orgfarm-de3be1735c-dev-ed.develop.my.site.com/defaulthelpcenter7Apr';

    formData = { name: '', email: '', subject: '', description: '' };

    get formActionUrl() {
        return 'https://webto.salesforce.com/servlet/servlet.WebToCase?encoding=UTF-8';
    }

    scrollTo(event) {
        const target = event.currentTarget.dataset.section;
        const el = this.template.querySelector(`[data-id="${target}"]`);
        if (el) {
            el.scrollIntoView({ behavior: 'smooth' });
        }
    }

    handleInput(event) {
        const field = event.target.name;
        this.formData = { ...this.formData, [field]: event.target.value };
    }

    handleSubmit() {
        const form = this.template.querySelector('form');
        if (form && form.reportValidity()) {
            form.submit();
        }
    }
}
