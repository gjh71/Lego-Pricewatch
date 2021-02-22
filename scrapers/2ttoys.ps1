Write-Verbose "Loaded 2tToys scraper"

$2ttoysInitialized = $false
$2ttoysSession = $null
$2ttoysPhpSession = $null

function Initialize-Scraper_2ttoys{
    if ($script:2ttoysInitialized){
        Write-Verbose("Already Initialized")
    }
    else{
        $uri = "https://www.2ttoys.nl/"
        $response = Invoke-WebRequest -Uri $uri -Method Get -SessionVariable session -usebasicparsing
        $script:2ttoysSession = $session
        $script:2ttoysPhpSession = $response.Headers["Set-Cookie"].Split(";")[0].Split("=")[1]
        $script:2ttoysInitialized = $true
    }
}


function Get-ScraperResult_2ttoys{
    param(
        [string] $LegoId
    )
    Initialize-Scraper_2ttoys
    $rv = $null
    $headers = @{
        "method"="GET"; 
        "authority"="www.2ttoys.nl"; 
        "scheme"="https"; 
        "path"="/contents/phpsearch/search.php?searchphrase={0}&=undefined&lang=nl&filterproc=filtersearch&fmt=html&searchFormRootUse=A&pgid=&sub=&searchFormSortBy=R-A&searchFormDisplayStyle=T&design=sfx-105_1&searchtermEnabled=&start_page=1&pagereset=1" -f $LegoId;
        "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36"; 
        "accept"="*/*"; 
        "sec-fetch-site"="same-origin"; 
        "sec-fetch-mode"="cors"; 
        "referer"="https://www.2ttoys.nl/contents/nl/search.php?searchphrase={0}&start_page=1&searchFormSortBy=R-A&searchFormRootUse=A" -f $LegoId; 
        "accept-encoding"="gzip, deflate, br"; 
        "accept-language"="nl-NL,nl;q=0.9,de-DE;q=0.8,de;q=0.7,fr-FR;q=0.6,fr;q=0.5,es-ES;q=0.4,es;q=0.3,en-US;q=0.2,en;q=0.1"; 
        "cookie" = "dadaproaffinity={0}" -f $script:2ttoysPhpSession
    }
<#
    $headers = @{
        "method"="GET"; 
        "authority"="www.2ttoys.nl"; 
        "scheme"="https"; 
        "cookie" = "dadaproaffinity={0}" -f $script:2ttoysPhpSession
    }
#>
    $uri = "https://www.2ttoys.nl/contents/phpsearch/search.php?searchphrase={0}&=undefined&lang=nl&filterproc=filtersearch&fmt=html&searchFormRootUse=A&pgid=&sub=&searchFormSortBy=R-A&searchFormDisplayStyle=T&design=sfx-105_1&searchtermEnabled=&start_page=1&pagereset=1" -f $LegoId

    $response = $null
    $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get -UseBasicParsing -SessionVariable $script:2ttoysSession
#    $response.content |out-file C:\temp\2ttoys.html
    
    #just retrieve relevant info from 'function initPrices'
    $rawBody = $response.content
    $regex = [regex] ".*\{id:\'(P[0-9]+)\'.*prc:([0-9]+.[0-9]{2}).*code:\'(.*)\'.*"
    $result = $rawbody -match $regex
    if ($result){
        #$price = [float]($Matches[2])
        #$model = $Matches[3].Split("~")[9]
        $rv = $Matches[2].replace(".", ",")
    }

    return $rv
}

# Get-ScraperResult_2tToys -LegoId 42054 #claes xerion
# Get-ScraperResult_2tToys -LegoId 42100 #liebherr
