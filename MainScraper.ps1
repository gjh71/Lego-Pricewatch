#requires -modules importexcel
Import-Module ImportExcel
$htmlAgilityPackDll = Join-Path $PSScriptRoot -ChildPath "lib\HtmlAgilityPack.dll"
# $htmlAgilityPackDll = Join-Path "." -ChildPath "lib\HtmlAgilityPack.dll"
[Reflection.Assembly]::LoadFile((Get-Item -path $htmlAgilityPackDll).FullName) | out-null

$scraperList = Get-ChildItem ("{0}\scrapers\*.ps1" -f $PSScriptRoot)
foreach ($scraper in $scraperList)
{
	Write-Host("Loading scraper: {0}" -f $scraper.Name) -ForegroundColor Green
    . $scraper.FullName
}

<#
todo: 
* addshops
* make multithreading
#>

$itemPath = Join-Path $PSScriptRoot -ChildPath items.xlsx
$sellersPath = Join-Path $PSScriptRoot -ChildPath sellers.xlsx

$items = Import-Excel $itemPath
$sellers = Import-Excel $sellersPath

function Get-PriceForItem{
	param(
		$item,
		$seller
	)
	$rv = $null
	$price = Invoke-Expression ("Get-ScraperResult_{0} -LegoId {1}" -f $seller.name, $item.id)
		
	if ($null -ne $price -and "" -ne $price){
        $rv = ([float]::Parse($price))
    }

	return $rv
}

$resultList = @()
#main loop
$cntItems = 0
foreach($item in $items){
	$itemObj = [pscustomobject]$item
    Write-Progress -Activity "Scraping" -Status "Searching prices for" -PercentComplete ($cntItems*100/($items.length)) -CurrentOperation $item.Name
	$cntSellers = 0
	$itemObj.ID = "{0}" -f $itemObj.ID
	$itemObj.minPrice = 10000
	$itemObj.maxPrice = 0
	foreach($seller in $sellers){
        Write-Progress -id 1 -Activity "Scraping" -Status "Scanning shop" -PercentComplete ($cntSellers*100/($sellers.length)) -CurrentOperation $seller.Name
		#determine price for item @ seller
		$price = Get-PriceForItem -item $item -seller $seller
        Write-host("Item: {0} bij {1}: {2}" -f $item.Name, $seller.Name, $price) -ForegroundColor Yellow
		if ($null -ne $price){
			if ($price -lt $itemObj.minPrice){
				$itemObj.minPrice = $price
				$itemObj.minSeller = $seller.Name
			}
			if ($price -gt $itemObj.maxPrice){
				$itemObj.maxPrice = $price
				$itemObj.maxSeller = $seller.Name
			}
		}
        $cntSellers++
		$itemObj | Add-Member -Name $seller.Name -Type NoteProperty -Value $price
	}
	Write-host("{0} {1} - {2} bij {3}, {4} bij {5}" -f $itemObj.id, $itemObj.Name, $itemObj.minPrice, $itemObj.minSeller, $itemObj.maxPrice, $itemObj.maxSeller) -ForegroundColor Yellow
    $cntItems++
	$resultList += $itemObj
}
$resultList | Out-GridView
$resultList | Export-Csv -Path ("scraperesults_{0:yyyyMMdd-HHmmss}.csv" -f (Get-Date)) -Delimiter ";" -NoTypeInformation
