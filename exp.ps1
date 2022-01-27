Param
(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $SubscriptionName,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $SourceNSG,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $DestinationNSG
)

# $csvFilePath = "$($home)\clouddrive\$SubscriptionName-nsg-rules.csv"
Set-AzContext -SubscriptionName $SubscriptionName | Out-Null

$srcNsg = Get-AzNetworkSecurityGroup -Name $SourceNSG
$sourceNSGRuleConfig = Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $srcNsg
# Write-Output $sourceNSGRuleConfig

$destNSG = Get-AzNetworkSecurityGroup -Name $DestinationNSG

foreach ( $ruleConfig in $sourceNSGRuleConfig ) {
    Add-AzNetworkSecurityRuleConfig -Name  -NetworkSecurityGroup $destNSG -Protocol $ruleConfig.Protocol `
        -Access $ruleConfig.Access -Priority $ruleConfig.Priority -Direction $ruleConfig.Direction `
        -SourceAddressPrefix $ruleConfig.SourceAddressPrefix -SourcePortRange $ruleConfig.SourcePortRange `
        -DestinationAddressPrefix $ruleConfig.DestinationAddressPrefix -DestinationPortRange $ruleConfig.DestinationPortRange `
        -Verbose
}

Get-AzNetworkSecurityGroup -Name $DestinationNSG | `
    Get-AzNetworkSecurityRuleConfig | `
    Write-Output