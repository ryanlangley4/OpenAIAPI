
<#
.SYNOPSIS
Initializes the OpenAI PowerShell module and checks environment variables.

.DESCRIPTION
This function clears the screen, welcomes the user, and checks if the OpenAI API Token and Organization ID are set. If not, it provides instructions on how to set them.

.PARAMETER None

.EXAMPLE
Initialize-OpenAIModule
# This command initializes the module and checks for necessary environment variables.

.NOTES
This function is typically run at the start of a session to ensure that all necessary settings are correctly configured.

.LINK
Set-OpenApiToken - For setting the API Token and Organization ID.
#>
function Initialize-OpenAIModule {
    [CmdletBinding()]
    param()

    # Clear the screen and display a welcome message
    Clear-Host
    Write-Host "Welcome to the OpenAI PowerShell Module!" -ForegroundColor Cyan
    Write-Host "This module helps interact with OpenAI's API for various tasks." -ForegroundColor Gray

    # Check if environment variables are set and suggest setting them if not
    if (-not $env:OPENAI_API_TOKEN -or -not $env:OPENAI_ORG_ID) {
        Write-Host "It looks like your API Token and Organization ID are not set." -ForegroundColor Yellow
        Write-Host "Please use Set-OpenApiToken to set these variables before proceeding:" -ForegroundColor Yellow
        Write-Host "`tSet-OpenApiToken -Token 'your_token_here' -OrgId 'your_org_id_here'" -ForegroundColor Green
    } else {
        Write-Host "API Token and Organization ID are set." -ForegroundColor Green
    }

    # Display a list of functions and their descriptions
    Write-Host "`nAvailable Functions in the Module:" -ForegroundColor Cyan
    Write-Host "`tSet-OpenApiToken - Sets the API Token and Organization ID as environment variables." -ForegroundColor Gray
    Write-Host "`tGet-OpenAITokenStatus - Checks the status of the API Token and Organization ID." -ForegroundColor Gray
    Write-Host "`tClear-OpenAIToken - Clears the API Token and Organization ID from the environment variables." -ForegroundColor Gray
    Write-Host "`tInvoke-AIQuery - Sends a prompt to the OpenAI API and retrieves the response." -ForegroundColor Gray
    Write-Host "`tInvoke-AIImageQuery - Sends an image and text prompt to the OpenAI API and retrieves the response." -ForegroundColor Gray
    Write-Host "`tGet-AIImage - Generates an image based on a prompt using DALL-E and saves it locally." -ForegroundColor Gray
	Write-Host "`tThis project is not affiliated with OpenAPI past an interface to their api."
}
<#
.SYNOPSIS
Test the presence of the OpenAI API Token and Organization ID in the environment variables.

.DESCRIPTION
This function checks whether both the OpenAI API Token and Organization ID are set in the environment variables. It returns true if both are set, otherwise it returns false.

.OUTPUTS
Boolean
Returns true if both keys are set, false otherwise.

.EXAMPLE
$isValid = Test-OpenAIKeys
if ($isValid) {
    Write-Host "API Keys are set."
} else {
    Write-Host "API Keys are not set. Use Set-OpenApiToken to set them."
}

.NOTES
This function is used internally by other functions in the module to ensure that the necessary API keys are available before making API calls.
#>
function Test-OpenAIKeys {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    # Check if both the API Token and Organization ID are set in the environment variables
    if ([string]::IsNullOrWhiteSpace($env:OPENAI_API_TOKEN)) {
        Write-Error "OpenAI API Token is not set in the environment variables."
        return $false
    }

    if ([string]::IsNullOrWhiteSpace($env:OPENAI_ORG_ID)) {
        Write-Error "OpenAI Organization ID is not set in the environment variables."
        return $false
    }

    # If both are set, return true
    return $true
}
<#
.SYNOPSIS
Sets the OpenAI API Token and Organization ID in the environment variables.

.DESCRIPTION
Prompts the user to enter the OpenAI API Token and Organization ID if they are not already provided as parameters. It then sets these values in the environment variables.

.PARAMETER Token
The OpenAI API Token. If not provided, the function will prompt for it.

.PARAMETER OrgId
The OpenAI Organization ID. If not provided, the function will prompt for it.

.EXAMPLE
Set-OpenApiToken -Token "your_api_token" -OrgId "your_org_id"

.NOTES
It is recommended to run this function before using any API-related functions to ensure all requests are authenticated.
#>

function Set-OpenApiToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Token,
        [Parameter(Mandatory=$false)]
        [string]$OrgId
    )
    
    if ([string]::IsNullOrWhiteSpace($Token)) {
        $Token = Read-Host "Please enter your OpenAI API Token"
        if ([string]::IsNullOrWhiteSpace($Token)) {
            Write-Error "No API Token provided. Exiting function."
            return
        }
    }
    
    if ([string]::IsNullOrWhiteSpace($OrgId)) {
        $OrgId = Read-Host "Please enter your OpenAI Organization ID"
        if ([string]::IsNullOrWhiteSpace($OrgId)) {
            Write-Error "No Organization ID provided. Exiting function."
            return
        }
    }

    $env:OPENAI_API_TOKEN = $Token
    $env:OPENAI_ORG_ID = $OrgId

    # Here, we test that the settings have been applied correctly
    if ((test-OpenAIKeys)) {
        Write-Verbose "API Token and Organization ID set and validated successfully."
    } else {
        Write-Error "Failed to validate the API Token and Organization ID settings."
    }
}
<#
.SYNOPSIS
Checks and displays the status of the OpenAI API Token and Organization ID.

.DESCRIPTION
Verifies if the OpenAI API Token and Organization ID are set and displays their status. It also makes a test API call to ensure they are valid.

.EXAMPLE
Get-OpenAITokenStatus
# This command checks the status of the environment variables and tests their validity with a simple API call.

.NOTES
Use this function to verify that your API credentials are set up correctly before proceeding with other API calls.
#>

function Get-OpenAITokenStatus {

    # Use the helper function to validate keys
    if (-not (test-OpenAIKeys)) {
        return
    }

    # If validation passes, retrieve and display the token statuses for additional clarity
    $tokenStatus = if ($env:OPENAI_API_TOKEN) { "set" } else { "not set" }
    $orgStatus = if ($env:OPENAI_ORG_ID) { "set" } else { "not set" }
    Write-Verbose "OpenAI API Token is $tokenStatus."
    Write-Verbose "OpenAI Organization ID is $orgStatus."

    # Prepare the API call
    $uri = "https://api.openai.com/v1/engines/text-davinci-003/completions"
    $body = @{
        prompt = "Say hello"
        max_tokens = 5
    } | ConvertTo-Json

    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $($env:OPENAI_API_TOKEN)"
        "OpenAI-Organization" = "$($env:OPENAI_ORG_ID)"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Verbose "API response received: $($response | ConvertTo-Json -Compress)"
    } catch {
        Write-Error "Failed to retrieve API response. Error: $_"
    }
}
<#
.SYNOPSIS
Clears the OpenAI API Token and Organization ID from the environment variables.

.DESCRIPTION
Removes the OpenAI API Token and Organization ID from the environment variables, effectively logging out the user from the API.

.EXAMPLE
Clear-OpenAIToken
# This command removes the API credentials from the environment.

.NOTES
Run this function when you need to change the API credentials or ensure that they are not stored in the session.
#>

function Clear-OpenAIToken {
    Remove-Item env:OPENAI_API_TOKEN -ErrorAction SilentlyContinue
    Remove-Item env:OPENAI_ORG_ID -ErrorAction SilentlyContinue
    $tokenStatus = if (-not [string]::IsNullOrWhiteSpace($env:OPENAI_API_TOKEN)) { "Failed to clear the OpenAI API Token." } else { "OpenAI API Token has been successfully cleared." }
    $orgStatus = if (-not [string]::IsNullOrWhiteSpace($env:OPENAI_ORG_ID)) { "Failed to clear the OpenAI Organization ID." } else { "OpenAI Organization ID has been successfully cleared." }
    Write-Host $tokenStatus
    Write-Host $orgStatus
}

<#
.SYNOPSIS
Sends a textual prompt to the OpenAI API and retrieves the response.

.DESCRIPTION
This function sends a user-provided prompt to the OpenAI API using the configured API keys and displays the AI's response.

.PARAMETER PromptVariable
The textual prompt to send to the OpenAI API.

.EXAMPLE
Invoke-AIQuery -PromptVariable "Tell me about the history of AI."

.NOTES
Ensure that the API Token and Organization ID are set before using this function to avoid authentication errors.
#>


function Invoke-AIQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PromptVariable
    )

    # Use the helper function to test API keys
    if (-not (test-OpenAIKeys)) {
        return
    }

    # Headers for OpenAI API authentication
    $headers = @{
        "Authorization" = "Bearer $($env:OPENAI_API_TOKEN)"
        "OpenAI-Organization" = "$($env:OPENAI_ORG_ID)"
        "Content-Type" = "application/json;charset=UTF-8"
    }

    $url = "https://api.openai.com/v1/chat/completions"
    $model = "gpt-4-turbo" # Current model gpt-4-turbo

    # Construct the body of the request using a more structured approach
    $body = @{
        model = $model
        messages = @(
            @{
                role = "system"
                content = "{$PromptVariable}"
            }
        )
    } | ConvertTo-Json

    try {
        # Sending the POST request to the OpenAI API
        $responseData = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers

        # Extracting and returning the content of the response
        $User_Display = $responseData.choices[0].message.content -replace "\n\n", ""
        Write-Output $User_Display
    } catch {
        Write-Error "Failed to retrieve response from OpenAI: $_"
    }
}
<#
.SYNOPSIS
Sends an image and text prompt to the OpenAI API and retrieves the response.

.DESCRIPTION
This function sends both text and an image to the OpenAI API for processing. It requires that the image be pre-encoded and the appropriate headers set.

.PARAMETER prompt
The text prompt to accompany the image.

.PARAMETER filename
The path to the image file to send.

.EXAMPLE
Invoke-AIImageQuery -prompt "What does this image represent?" -filename "path\to\your\image.png"

.NOTES
Ensure that the API Token and Organization ID are set and the image file exists at the specified path.
#>

function Invoke-AIImageQuery {
	  [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$prompt,
        [Parameter(Mandatory = $true)]
        [string]$filename
    )

    if (-not $env:OPENAI_API_TOKEN -or -not $env:OPENAI_ORG_ID) {
        Write-Error "API Token and Organization ID must be set in the environment variables."
        return
    }

    if (-not (Test-Path $filename)) {
        Write-Error "No file found at $filename"
        return
    }

    $headers = @{
        "Authorization" = "Bearer $($env:OPENAI_API_TOKEN)"
        "OpenAI-Organization" = "$($env:OPENAI_ORG_ID)"
        "Content-Type" = "application/json;charset=UTF-8"
    }

    $base64_image = [Convert]::ToBase64String((Get-Content -Path $filename -Encoding Byte))
    $model = "gpt-4-turbo"
    $url = "https://api.openai.com/v1/chat/completions"

    # Construct the body of the request
    $body = @{
        model = $model
        messages = @(
            @{
                role = "user"
                content = @(
                    @{
                        type = "text"
                        text = $prompt
                    },
                    @{
                        type = "image_url"
                        image_url = @{
                            url = "data:image/png;base64,{" + $base64_image+ "}"
                        }
                    }
                )
            }
        )
        max_tokens = 500
    } | ConvertTo-Json  -Depth 10

    try {
        $response = Invoke-WebRequest -Uri $url -Method POST -Body $body -Headers $headers -UseBasicParsing
        $responseData = $response.Content | ConvertFrom-Json

        if ($responseData.choices.message.content.length -ne 0) {
            return $responseData.choices.message.content
        } else {
            Write-Error "ERROR: $($responseData)"
            return
        }
    } catch {
        Write-Error "Failed to retrieve response from OpenAI: $_"
    }
}
<#
.SYNOPSIS
Generates an image based on a prompt using the DALL-E model and saves it locally.

.DESCRIPTION
This function calls the OpenAI API to generate an image based on the provided prompt. The generated image is saved to the specified file path.

.PARAMETER prompt
The prompt based on which the image is to be generated.

.PARAMETER file
Optional. The file path where the generated image will be saved. If not specified, it defaults to the current directory with a name "OpenAI_generated_image.png".

.EXAMPLE
Invoke-AIImage -prompt "A futuristic cityscape" -file "C:\Images\cityscape.png"

.NOTES
This function requires an active internet connection and valid API credentials. Ensure that the output directory exists and is writable.
#>

function Invoke-AIImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$prompt,
        [Parameter(Mandatory = $false)]
        [string]$file
    )

    # test the environment variables for API token and Org ID
    if (-not (test-OpenAIKeys)) {
        return
    }

    # Determine the output file path
    if ([string]::IsNullOrWhiteSpace($file)) {
        $file = Join-Path (Get-Location) "OpenAI_generated_image.png"
    } else {
        if (-not [IO.Path]::IsPathRooted($file)) {
            $file = Join-Path (Get-Location) $file
        }

        $directory = Split-Path -Path $file -Parent
        if (-not (Test-Path -Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        $extension = [IO.Path]::GetExtension($file)
        if ($extension -ne ".png") {
            if ($extension) {
                $file = [IO.Path]::ChangeExtension($file, ".png")
            } else {
                $file += ".png"
            }
        }
    }

    $headers = @{
        "Authorization" = "Bearer $($env:OPENAI_API_TOKEN)"
        "OpenAI-Organization" = "$($env:OPENAI_ORG_ID)"
        "Content-Type" = "application/json"
    }

    $model = "dall-e-3"
    $url = "https://api.openai.com/v1/images/generations"
    $params = @{
        model = $model
        prompt = $prompt
        n = 1
        quality = "hd"
        size = "1024x1024"
    } | ConvertTo-Json

    try {
        # Make the API request to generate the image
        $response = Invoke-WebRequest -Uri $url -Method POST -Body $params -Headers $headers -UseBasicParsing
        $responseData = $response.Content | ConvertFrom-Json

        if ($responseData.data.url) {
            $imageUrl = $responseData.data.url
            # Download the generated image
            Invoke-WebRequest -Uri $imageUrl -OutFile $file
            Write-Host "Image successfully saved to $file"
        } else {
            Write-Error "Failed to obtain an image URL from the response."
            return
        }
    } catch {
        Write-Error "Failed to retrieve response from OpenAI: $_"
    }
}

<#
.SYNOPSIS
Generates spoken audio from text using OpenAI's Text-to-Speech API and saves it as an MP3 file.

.DESCRIPTION
This function sends a text input to OpenAI's TTS API, saves the generated speech as an MP3 file, and optionally plays the audio.

.PARAMETER Text
The text to be converted into speech.

.PARAMETER Voice
The voice to be used for speech generation. Default voices are alloy, echo, fable, onyx, nova, and shimmer. Randomly selected if not specified.

.PARAMETER FilePath
The file path where the audio should be saved.

.PARAMETER PlayAudio
Specifies whether to play the audio after it is saved. Defaults to False.

.EXAMPLE
Invoke-SpeechSynthesis -Text "Hello, world!" -Voice "echo" -FilePath ".\hello.mp3" -PlayAudio $true

.NOTES
Ensure that the API Token is set before using this function.
#>
function Invoke-SpeechSynthesis {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $false)]
        [ValidateSet("alloy", "echo", "fable", "onyx", "nova", "shimmer")]
        [string]$Voice = (Get-Random -InputObject @("alloy", "echo", "fable", "onyx", "nova", "shimmer")),

        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [bool]$PlayAudio = $false
    )

    if (-not (Test-OpenAIKeys)) {
        Write-Error "API Token and Organization ID must be set in the environment variables."
        return
    }

    $headers = @{
        "Authorization" = "Bearer $($env:OPENAI_API_TOKEN)"
        "Content-Type" = "application/json"
    }

    $body = @{
        model = "tts-1"
        input = $Text
        voice = $Voice
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "https://api.openai.com/v1/audio/speech" -Method Post -Headers $headers -Body $body -OutFile $FilePath
        Write-Host "Audio file saved to $FilePath" -ForegroundColor Green

        if ($PlayAudio) {
            Write-Host "Playing audio file..." -ForegroundColor Yellow
            Start-Process -FilePath $FilePath
        }
    } catch {
        Write-Error "Failed to generate speech from text : $_"
    }
}

Initialize-OpenAIModule
