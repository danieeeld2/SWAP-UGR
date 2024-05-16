import nmap

# Predefined
separator = "********************************************"

# Functions
def printFoundHosts( allHostsList : list[str] ):
    if len( allHostsList ) > 0:
        print( "\n*--- Dispositivos encontrados:\n" )

        for i, host in enumerate( allHostsList ):
            print( separator )
            print( f"*** Dispositivo #{ i + 1 } ***" )
            print( f"Nombre:        { devScanner[host].hostname() }" )
            print( f"Dirección Ip:  { host }" )

            if 'mac' in devScanner[host]['addresses']:
                print( f"Dirección MAC: { devScanner[host]['addresses']['mac'] }" )

            print( f"Estado:        { devScanner[host].state() }" )
            
            protocolsList = devScanner[host].all_protocols()

            if len( protocolsList ) > 0:
                print( "\n* Protocolos *" )

                for proto in devScanner[host].all_protocols():
                    print( f"\tProtocolo: { proto }" )
                    lport = devScanner[host][proto].keys()
                    #lport.sort()
                    for port in lport:
                        print ( f"\t\tPuerto: { port }\tEstado: { devScanner[host][proto][port]['state'] }" )

        print( separator )
    else:
        print( "\nNo se encontraron dispositivos en el segmento de red indicado." )


### Script Body Code
print( "\n*** Network Devices Scanner ***\n" )

devScanner = nmap.PortScanner()

ip = input( "Ingrese el Rango Ip: " )

print( "\nBuscando dispositivos presentes en la red del rango Ip indicado: ", ip )
print( "Un momento por favor, en breve se mostrará el resultado.\nDetectando..." )

devScanner.scan( ip )

printFoundHosts( devScanner.all_hosts() )
