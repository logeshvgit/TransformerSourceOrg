/**
 * Seeds 10 Product2 rows for PrintCo demo catalog (matches static resource SKUs).
 * Run: sf apex run --file scripts/apex/seed_printco_products.apex --target-org <alias>
 */
List<Product2> rows = new List<Product2>{
    new Product2(Name = 'PrintCo Press 5000', ProductCode = 'PC-PRESS-5000', IsActive = true, Family = 'Hardware'),
    new Product2(Name = 'Wide Format 36"', ProductCode = 'PC-WIDE-36', IsActive = true, Family = 'Hardware'),
    new Product2(Name = 'Color Production A3', ProductCode = 'PC-COLOR-A3', IsActive = true, Family = 'Hardware'),
    new Product2(Name = 'Mono Fleet A4', ProductCode = 'PC-MONO-A4', IsActive = true, Family = 'Hardware'),
    new Product2(Name = 'Booklet Finisher Pro', ProductCode = 'PC-FINISH-BOOK', IsActive = true, Family = 'Supplies'),
    new Product2(Name = 'Fiery RIP Module', ProductCode = 'PC-FIERY-RIP', IsActive = true, Family = 'Software'),
    new Product2(Name = 'Toner Set CMYK', ProductCode = 'PC-TONER-CMYK', IsActive = true, Family = 'Supplies'),
    new Product2(Name = 'Fuser Maintenance Kit', ProductCode = 'PC-FUSER-KIT', IsActive = true, Family = 'Supplies'),
    new Product2(Name = 'Gloss Media Roll', ProductCode = 'PC-MEDIA-GLOSS', IsActive = true, Family = 'Supplies'),
    new Product2(Name = 'Gold SLA Add-on', ProductCode = 'PC-SLA-GOLD', IsActive = true, Family = 'Services')
};
insert rows;
System.debug('Inserted ' + rows.size() + ' products.');
