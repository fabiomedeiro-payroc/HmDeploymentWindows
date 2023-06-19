$file = "C:\windows\System32\drivers\etc\hosts"
$hostfile = Get-Content $file
$contentToAdd = "
# IP address of WEB server VM
192.168.56.3 vagrant.wntps.com
192.168.56.3 lcashflows.wntps.com
192.168.56.3 lpayius.wntps.com
192.168.56.3 lpayjack.wntps.com
192.168.56.3 lpago.wntps.com
192.168.56.3 lpivotal.wntps.com
192.168.56.3 lanywherecom.wntps.com
192.168.56.3 lctpayment.wntps.com
192.168.56.3 lpayconex.wntps:w.com
192.168.56.3 lpayzone.wntps.com
192.168.56.3 lgoepay.wntps.com
192.168.56.3 lfirstcitizens.wntps.com
192.168.56.3 lgoldstarpayments.wntps.com
192.168.56.3 payments-vantagegateway-com.wntps.com
192.168.56.3 payments-gochipnow-com.wntps.com
192.168.56.3 mobilepayments-jncb-com.wntps.com
192.168.56.3 abacuspay-cmtgroup-com.wntps.com
192.168.56.3 testpayments-itsco-net.wntps.com
192.168.56.8 simulator.wntps.com
192.168.56.8 sftp.wntps.com
"
$hostfile += $contentToAdd
Set-Content -Path $file -Value $hostfile -Force
