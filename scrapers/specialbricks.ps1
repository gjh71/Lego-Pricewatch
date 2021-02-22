Write-Verbose "Loaded SpecialBricks scraper"

function Get-ScraperResult_SpecialBricks{
    param(
        [string] $LegoId
    )

    $rv = $null
    $uri = "https://specialbricks.nl/?s={0}&post_type=product" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div",
        "/div[@class='site-content']",
        "/main",
        "/div[@class='tg-container']",
        "/div[@id='primary']",
        "/div",
        "/div[@class='summary entry-summary']",
        ""))

    # probably 1 result
    foreach($node in $searchResults){
        $priceNode = $node.SelectNodes("./p[@class='price']/span[@class='woocommerce-Price-amount amount']")
        $modelNode = $node.SelectNodes("./h1")
        $model = ""
        if ($modelNode.innerText -match '^([0-9]+)\D*'){
            $model = $Matches[1]
        }
        $price = ""
        if ($priceNode.innerText -match '\D*(\d{1,},\d{2}).*'){
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

# Get-ScraperResult_SpecialBricks -LegoId 42054 #claes xerion