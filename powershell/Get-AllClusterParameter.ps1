$cn = Get-ClusterResource | Select-Object Name
$cn | ForEach-Object {

	Get-ClusterResource $cn.Name | Get-ClusterParameter

}
