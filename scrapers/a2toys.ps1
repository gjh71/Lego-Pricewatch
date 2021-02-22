Write-Verbose "Loaded A2Ttoys scraper"

function Get-ScraperResult_A2Toys{
    param(
        [string] $LegoId
    )

    $rv = $null
    $uri = "https://www.a2toys.nl/epages/63446990.sf/nl_NL/?ObjectID=12982655&ViewAction=FacetedSearchProducts&SearchString={0}" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div",
        "/div[@class='Middle']",
        "/div[@class='ContentArea']",
        "/div[@class='ContentAreaInner']",
        "/div[@class='ContentAreaWrapper']",
        "/div",
        "/div[@class='HotDealList']",
        ""
        ))

    foreach($node in $searchResults){
        $modelNode = $node.SelectNodes(-join ("./div[@class='HotDeal']",
            "/div[@class='HotDealFoot']",
            "/div",
            "/div[@class='InfoArea']",
            "/a[@class='ProductName']",
            ""
            ))
        $model = ""
        if ($modelNode.innerText -match '\s*LEGO\s(Technic\s|Creator\s)?(\d+)\s.*'){
            $model = $Matches[2]
        }
        if ($model -eq $LegoId){
            $priceNode = $node.SelectNodes(-join ("./div[@class='HotDeal']",
                "/div[@class='HotDealFoot']",
                "/div",
                "/span[@class='Price']",
                "/span[@class='price-value']",
                "/span[@itemprop='price']",
                ""
                ))
 
            if ($priceNode.innerText -match '(\d{1,},\d{2}).*'){
                $rv = $Matches[1]
                break;
            }
        }
    }

    return $rv
}

 # Get-ScraperResult_A2Toys -LegoId 42100