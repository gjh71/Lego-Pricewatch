Write-Verbose "Loaded Bricksdirect scraper"

function Get-ScraperResult_BricksDirect{
    param(
        [string] $LegoId
    )
    $rv = $null
    $uri = "https://bricksdirect.com/nl/zoeken?controller=search&orderby=position&orderway=desc&search_query={0}&submit_search=" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div[@id='page']",
        "/div[@class='columns-container']",
        "/div",
        "/div[@class='inner_container']",
        "/div[@class='inner_container_sub']",
        "/div[@id='columns_inner']",
        "/div",
        "/ul[@class='product_list grid row']"
        ))
    foreach($node in $searchResults){
        $priceNode = $node.SelectNodes(-join ("./li",
            "/div[@class='product-container']",
            "/div[@class='right-block']",
            "/div[@class='content_price']",
            "/span[@class='price product-price']"
            ))
        if ($priceNode.innerText -match '.* (\d{1,},\d{2}).*'){
            $rv = $Matches[1]
        }
    }

    return $rv
}

#Get-ScraperResult_BricksDirect -LegoId 42054
#Get-ScraperResult_BricksDirect -LegoId 42078
