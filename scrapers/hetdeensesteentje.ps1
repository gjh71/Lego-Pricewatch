Write-Verbose "Loaded HetDeenseSteentje scraper"

$deenseSteentjeInitialized = $false
$deenseSteentjeSession = $null
$deensSteentjePhpSession = $null

function Initialize-Scraper_HetDeenseSteentje{
    if ($script:deenseSteentjeInitialized){
        Write-Verbose("Already Initialized")
    }
    else{
        $uri = "https://www.hetdeensesteentje.nl/nl/"
        $response = Invoke-WebRequest -Uri $uri -Method Get -SessionVariable session -usebasicparsing
        $script:deenseSteentjeSession = $session
        $script:deensSteentjePhpSession = $response.Headers["Set-Cookie"].Split(";")[0].Split("=")[1]
        $script:deenseSteentjeInitialized = $true
    }
}

function Get-ScraperResult_HetDeenseSteentje{
    param(
        [string] $LegoId
    )
    Initialize-Scraper_HetDeenseSteentje
    $rv = $null
    $header = @{
        PHPSESSID = $script:deensSteentjePhpSession
    }
    $uri = "https://www.hetdeensesteentje.nl/nl/search/"
    $body = @{
        string = "{0}" -f $LegoId
    }
    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Method Post -Headers $header -Body $body -UseBasicParsing -SessionVariable $script:deenseSteentjeSession

    $pHAPDoc = New-Object HtmlAgilityPack.HtmlDocument
    $pHapDoc.LoadHtml($response)
    $searchResults = $pHAPDoc.DocumentNode.SelectNodes(-join ("/html/body",
        "/div[@id='cntr']",
        "/div[@id='wrap']",
        "/div[@id='content']",
        "/section[@id='right']",
        "/ul",
        ""))
    # 1 node result
    foreach($node in $searchResults){
        $priceNode = $node.SelectNodes("./li/div[@class='text']/hgroup/a/div[@class='price']/h3")
        $modelNode = $node.SelectNodes("./li/div[@class='text']/hgroup/a/h2")
        $model = ""
        if ($modelNode.innerText -match '\D*([0-9]+)\D*'){
            $model = $Matches[1]
        }
        $price = ""
        if ($priceNode.innerText -match '\D*(\d{1,}.\d{2}).*'){
            $price = $Matches[1]
        }
        if ($model -eq $LegoId){
            $rv = [float]$price
        }
    }

    return $rv
}

# Get-ScraperResult_HetDeenseSteentje -LegoId 42100
#Get-ScraperResult_HetDeenseSteentje -LegoId 42107
