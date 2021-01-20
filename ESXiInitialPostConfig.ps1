$credentials = get-credential
# Need to replace this with getting the values via CSV
$esxhosts = @(
'esxi-01'
'esxi-02'

)
$domainlFullName='lab.local'
$domainUser='administrator'
$domainPassword='P@ssw0rd'
 
$esxhosts | foreach-object {
  
  connect-viserver $_ -credential $credentials
  
  write-output "configuring NTP service"
  Get-VMHostService | Where-Object {$_.key -eq "ntpd" } | Set-VMHostService -policy "on" | out-null 

  write-output "configuring SSH service"
  Get-VMHostService | Where-Object {$_.key -eq "TSM-SSH" } | Set-VMHostService -policy "on" | out-null

  write-output "Set Suppress Warning Value"
  Get-VMHost | Get-AdvancedSetting -Name UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$false

  write-output "Set Password Policy"
  Get-VMHost | Get-AdvancedSetting -Name Security.AccountLockFailures | Set-AdvancedSetting -Value 5 -Confirm:$false
  Get-VMHost | Get-AdvancedSetting -Name Security.AccountUnlockTime | Set-AdvancedSetting -Value 1800 -Confirm:$false
  Get-VMHost | Get-AdvancedSetting -Name Security.PasswordHistory | Set-AdvancedSetting -Value 12 -Confirm:$false
  Get-VMHost | Get-AdvancedSetting -Name Security.PasswordMaxDays | Set-AdvancedSetting -Value 60 -Confirm:$false
  Get-VMHost | Get-AdvancedSetting -Name Security.PasswordQualityControl | Set-AdvancedSetting -Value "retry=3 min=disabled,disabled,10,7,7" -Confirm:$false

  write-output "Modify Power Management Policy to High Performance "
  (Get-View (Get-VMHost | Get-View).ConfigManager.PowerSystem).ConfigurePowerPolicy(1)


  disconnect-viserver * -Confirm:$false -Force
 
}
