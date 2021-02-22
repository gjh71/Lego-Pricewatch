Write-Verbose "Loaded Amazon-NL scraper"

$Script:AmazonNL_Initialised = $false
$Script:AmazonNL_Session = $null

function Initialize-Scraper_Amazon-NL{
    if ($Script:AmazonNL_Initialised){
        Write-Verbose("Already initialised")
    }
    else{
        $uri = "https://www.amazon.nl/"
        $response = Invoke-WebRequest -Uri $uri -Method Get -SessionVariable session -usebasicparsing
        $Script:AmazonNL_Session = $session
        $Script:AmazonNL_Initialised = $true
    }
}

function Get-ScraperResult_Amazon-NL{
    param(
        [string] $LegoId
    )
    Initialize-Scraper_Amazon-Nl

    $rv = $null
    $uri = "https://www.amazon.nl/s?k={0}&i=toys&__mk_nl_NL=123&ref=nb_sb_noss" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing -WebSession $Script:AmazonNL_Session

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $response.content | out-file ("c:\temp\content.html")
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body/div[@id='a-page']",
        "/div",
        "/div",
        "/div",
        "/div[@class='sg-col-inner']",
        "/span",
        "/div",
        "/div"
        ))
    $cnt=0
    foreach($node in $searchResults){
        $modelNode = $node.SelectNodes(-join ("./div[@class='sg-col-inner']",
            "/span",
            "/div",
            "/div/div/h2/a/span",
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
                "/div",
                "/div",
                "/div",
                "/div",
                "/div[@class='a-row']",
                "/a",
                "/span/span",
                "/span[@class='a-price-whole']",
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

#Get-ScraperResult_Amazon-NL -LegoId 42100 #liebherr
#Get-ScraperResult_Amazon-NL -LegoId 10252 # beetle