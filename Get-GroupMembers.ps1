function Get-GroupMembers {
    [cmdletbinding()]

    param(
        [Parameter(Mandatory=$True)][string]$SearchBase,
        [string]$SearchScope = 'Base'
    )
    
    try {
        Write-Verbose 'Attempting to import the ActiveDirectory module.'
        Import-Module -Name ActiveDirectory
    }
    catch {
        Write-Error 'ERROR:  There was an error importing the module.'
    }

    $ADGroups = Get-ADGroup -Filter * -SearchBase $SearchBase

    ForEach ($Group in $ADGroups) {
        $ADGroupMembers = Get-ADGroupMember -Identity $Group.SID
        ForEach ($Member in $ADGroupMembers){
            try { $UserInfo = Get-ADUser -Identity ($Member.distinguishedName) -Properties * -ErrorAction SilentlyContinue }
            catch { Write-Verbose 'Get-ADUser info failed.'}
            $Props = [ordered]@{
                'GroupName' = $Group.Name
                'Type' = $Group.GroupCategory
                'Member' = $Member.Name
                'SamAccountName' = $Member.SamAccountName
                'Department' = $UserInfo.Department
            }
        
            $Obj = New-Object -TypeName PSObject -Property $Props
            Write-Output $Obj
        }
    }
}