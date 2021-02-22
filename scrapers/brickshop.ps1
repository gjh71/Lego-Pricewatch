Write-Verbose "Loaded BrickShop scraper"

$BrickShopInitialized = $false
$BrickShopSession = $null
$BrickShopPhpSession = $null

function Initialize-Scraper_BrickShop{
    if ($script:BrickShopInitialized){
        Write-Verbose("Already Initialized")
    }
    else{
        $uri = "https://www.brickshop.nl/"
        $response = Invoke-WebRequest -Uri $uri -Method Get -SessionVariable session -usebasicparsing
        $script:BrickShopSession = $session
        $script:BrickShopPhpSession = $response.Headers["Set-Cookie"].Split(";")[0].Split("=")[1]
        $script:BrickShopInitialized = $true
    }
}


function Get-ScraperResult_BrickShop{
    param(
        [string] $LegoId
    )
    Initialize-Scraper_BrickShop
    $rv = $null
    $uri = "https://www.brickshop.nl/index2.php?option=com_universal_ajax_live_search&format=raw&search_exp={0}" -f $LegoId

    $response = $null
    $response = Invoke-RestMethod -Uri $uri -Method Get -UseBasicParsing -SessionVariable $script:BrickShopSession
    $uri = ""
    foreach($result in $response.psobject.properties){
        if ($null -ne $result.value.text -and $result.value.text -notlike "<br />*"){
            $uri = "https://www.brickshop.nl{0}" -f $result.value.href
            break;
        }
    }

    if ($uri -ne ""){
        $response = $null
        $response = Invoke-WebRequest -Uri $uri -Headers $header -Method Get -UseBasicParsing -SessionVariable $script:BrickShopSession

        $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
        $pHapDoc.LoadHtml($response)
        $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body",
            "/div[@id='art-main']",
            "/div[@class='art-sheet']",
            "/div[@class='art-sheet-body']",
            "/div[@class='art-content-layout']",
            "/div[@class='art-content-layout-row']",
            "/div[@class='art-layout-cell art-content']",
            "/div[@class='art-post']",
            "/div[@class='art-post-body']",
            "/div[@class='art-post-inner']",
            "/div[@class='art-postcontent']",
            "/div[@id='vmMainPage']",
            "/table",
            ""))

        # probably 1 result
        foreach($node in $searchResults){
            $modelNode = $node.SelectNodes(-join ("./tr",
                        "/td",
                        "/h1",
                        ""))
            $priceNode = $node.SelectNodes(-join ("./tr",
                        "/td[@class='vmCartContainer_td']",
                        "/div",
                        "/div",
                        "/span[@class='productPrice']",
                        ""))

            $model = ""
            if ($modelNode.innerText -match '\D*([0-9]+)\D*'){
                $model = $Matches[1]
            }
            $price = ""
            if ($priceNode.innerText -match '\D*(\d{1,},\d{2})\D*'){
                $price = $Matches[1]
            }
            if ($model -eq $LegoId){
                $rv = $price
                break;
            }
        }
    }

    return $rv
}

#Get-ScraperResult_BrickShop -LegoId 42054 #claes xerion
#Get-ScraperResult_BrickShop -LegoId 42100 #liebherr
