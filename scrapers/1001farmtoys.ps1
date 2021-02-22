Write-Verbose "Loaded 1001Farmtoys scraper"
function Get-ScraperResult_1001Farmtoys{
    param(
        [string] $LegoId
    )
    $rv = $null
    $uri = "https://1001farmtoys.nl/search_result.php?keyword={0}" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes("//div[@id='search_results']/div[@class='head-specials']/div[@class='product_block']")
    foreach($node in $searchResults){
        $priceNode = $node.SelectNodes("./div/div[@class='price_menu_block']/div[@class='price_normal']")
        $modelNode = $node.SelectNodes("./div/div[@class='price_menu_block']/div[@class='product_block_model']")
        if ($null -eq $priceNode){
            $priceNode = $node.SelectNodes("./div/div[@class='price_menu_block price_special_menu_block']/div[@class='price_normal']")
            $modelNode = $node.SelectNodes("./div/div[@class='price_menu_block price_special_menu_block']/div[@class='product_block_model']")
        }
        $model = ""
        if ($modelNode.innerText -match '\D*([0-9]+)\D*'){
            $model = $Matches[1]
        }
        $price = ""
        if ($priceNode.innerText -match '.*&euro;\s*(\d{1,},\d{2}).*'){
            $price = $Matches[1]
        }
        if ($model -eq $LegoId){
            $rv = $price
        }
        else {
#            Write-Host ("{0} no match for {1}" -f $model, $LegoId)
        }
    }

    return $rv
}

# Get-ScraperResult_1001Farmtoys -LegoId 42054