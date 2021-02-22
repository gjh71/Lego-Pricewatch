Write-Verbose "Loaded Amazon-De scraper"

$Script:AmazonDe_Initialised = $false
$Script:AmazonDe_Session = $null

function Initialize-Scraper_Amazon-De{
    if ($Script:AmazonDe_Initialised){
        Write-Verbose("Already initialised")
    }
    else{
        $uri = "https://www.amazon.de/"
        $response = Invoke-WebRequest -Uri $uri -Method Get -SessionVariable session -usebasicparsing
        $Script:AmazonDe_Session = $session
        $Script:AmazonDe_Initialised = $true
    }
}

function Get-ScraperResult_Amazon-De{
    param(
        [string] $LegoId
    )
    Initialize-Scraper_Amazon-De

    $rv = $null
    $uri = "https://www.amazon.de/s?k={0}&i=toys&__mk_nl_NL=123&ref=nb_sb_noss" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -WebSession $Script:AmazonDe_Session

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div[@id='a-page']",
        "/div[@id='search']",
        "/div[@class='s-desktop-width-max s-desktop-content sg-row']",
        "/div",
        "/div[@class='sg-col-inner']",
        "/span",
        "/div[@class='s-result-list s-search-results sg-row']",
        "/div"
        ))
    foreach($node in $searchResults){
        $modelNode = $node.SelectNodes(-join ("./div[@class='sg-col-inner']",
            "/span",
            "/div[@class='s-expand-height s-include-content-margin s-border-bottom']",
            "/div[@class='a-section a-spacing-medium']",
            "/div[@class='a-section a-spacing-none a-spacing-top-small']",
            "/h2",
            "/a",
            "/span",
            ""
            ))
            $model = ""
            $result = $modelNode.innerText | select-string 'lego (technic|creator|)?\D*(\d{3,6})' -AllMatches
            if ($result.matches.Count -gt 0){
                $model = $result.matches[$result.matches.Count-1].Groups[2].value
            }
            if ($model -eq $LegoId){
                $priceNode = $node.SelectNodes(-join ("./div[@class='sg-col-inner']",
                "/span",
                "/div[@class='s-expand-height s-include-content-margin s-border-bottom']",
                "/div[@class='a-section a-spacing-medium']",
                "/div[@class='a-section a-spacing-none a-spacing-top-mini']",
                "/div[@class='a-row a-size-base a-color-secondary']",
                "/span[@class='a-color-base']",
                ""
                ))
            if ($priceNode.innerText -match '(\d{1,},\d{2})\D*'){
                $rv = $Matches[1]
                break;
            }
        }
    }

    return $rv
}

#Get-ScraperResult_Amazon-De -LegoId 42100 #liebherr
#Get-ScraperResult_Amazon-De -LegoId 10252 #beetle