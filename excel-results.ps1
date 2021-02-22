Import-Module ImportExcel
$results = Import-Excel .\scraperesults.xlsx

$results[8].minPrice
# hmmm, formulas not available

