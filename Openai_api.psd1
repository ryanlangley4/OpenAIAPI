@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'OpenAI_API.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '5279616e-4c61-6e67-4f70-656e41504924'

    # Author of this module
    Author = 'Ryan Langley'

    # Company or vendor of this module
    CompanyName = 'NoCompany'

    # Copyright statement for this module
    Copyright = '(c) 2024 Ryan Langley. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'This module provides functions for interfacing with OpenAI API, allowing for tasks such as text generation, audio transcription, and image processing.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('OpenAI', 'GPT', 'API', 'Automation')

            # A URL to the license for this module.
            LicenseUri = 'http://example.com/license'

            # A URL to an icon for this module.
            IconUri = 'http://example.com/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of the OpenAI_API module, providing comprehensive access to OpenAI services.'
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI = 'http://example.com/help'
}
