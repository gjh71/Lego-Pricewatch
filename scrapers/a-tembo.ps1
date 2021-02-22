Write-Verbose "Loaded A-Tembo scraper"

function Get-ScraperResult_A-Tembo{
    param(
        [string] $LegoId
    )

    $rv = $null
    $uri = "https://www.a-tembo.nl/zoeken/product/listing?filter_Zoeken_1={0}" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div",
        "/div[@class='uk-container uk-container-center']",
        "/div[@class='tm-middle uk-grid']",
        "/div[@class='tm-main uk-width-medium-3-5 uk-push-1-5']",
        "/main",
        "/div[@class='hikashop_category_information hikashop_products_listing_main hikashop_product_listing_2 filter_refresh_div']",
        "/div[@class='hikashop_products_listing']",
        "/div[@class='hikashop_products']",
        "/table",
        "/tbody",
        ""))

    # probably 1 result
    foreach($node in $searchResults){
        $priceNode = $node.SelectNodes(-join ("./tr",
                    "/td[@class='hikashop_product_name_row']",
                    "/span[@class='hikashop_product_price_full']",
                    "/span[@class='hikashop_product_price hikashop_product_price_0']",
                    ""))
        $modelNode = $node.SelectNodes(-join ("./tr",
                    "/td[@class='hikashop_product_name_row']",
                    "/span[@class='hikashop_product_code']",
                    ""))

        $model = ($modelNode.innerText).Trim()
        $price = ""
        if ($priceNode.innerText -match '\D*(\d{1,},\d{2})\D*'){
            $price = $Matches[1]
        }
        if ($model -eq $LegoId){
            $rv = $price
            break;
        }
    }

    return $rv
}

# Get-ScraperResult_A-Tembo -LegoId 42054 #claes xerion
# Get-ScraperResult_A-Tembo -LegoId 42100 #liebherr
