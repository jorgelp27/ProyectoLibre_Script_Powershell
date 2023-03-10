


Function menu {
    Clear-Host
    Write-Host "Gestion de sistema"
    Write-Host "1. Copia de seguridad usuario"
    Write-Host "2. Configuracion de Permisos  "
    Write-Host "3. Informacion del sistema "
    Write-Host "4. Informacion de Servicios "
    Write-Host "5. Informacion de Red "
    Write-Host "6. Salir"
}
 
menu


while(($inp = Read-Host -Prompt "---------- Elige una opcion ----------") -ne "6"){
 
switch($inp){
        1 {
            Clear-Host
            Write-Host "------------------------------------";
            Write-Host "Copia de seguridad"; 
            Write-Host "------------------------------------";

                function copiadeseguridad {

                        Write-Host "Lista de usuarios que se encuentran en el sistema`n"

                            $usuarios = Get-ADUser -Filter *


                            $objeto = $usuarios.Name

                            $objeto

                            $NameUser=Read-host "Escriba el nombre de usuario del que desea hacer la copia de seguridad`n"


                        # Definir la ruta de la carpeta a respaldar

                            $origen = "C:\Users\$NameUser"

                        # Definir la ruta de destino para la copia de seguridad

                            $destino = "C:\Backup"

                        # Crear una variable con el nombre del archivo de copia de seguridad

                            $nombreArchivo = "backup_" + (Get-Date -Format "yyyyMMdd_HHmm") + ".zip"

                        # Crear la copia de seguridad

                            Compress-Archive -Path $origen -DestinationPath "$destino\$nombreArchivo"

                        # Mostrar un mensaje de confirmación en color verde

                        Write-Host "La copia de seguridad se ha creado correctamente en $destino\$nombreArchivo.`n" -ForegroundColor green

                        }

                copiadeseguridad

            pause;
            break
        }

        2 {
            Clear-Host
            Write-Host "-------------------------";
            Write-Host "Configurar permisos"; 
            Write-Host "-------------------------";
                
                function permisos {

                # Definir la ruta de la carpeta para la cual se configurarán los permisos

                    $carpeta = Read-host "Escribe el directorio al que dese aplicar permisos"

                # variable que almacenara el nombre del usuarios y los permisos que le demos por pantalla.

                    $NameUser=Read-host "Escriba el nombre de usuario al que desea darle permisos"

                    Write-Host "Lista de permisos`n" -ForegroundColor green

                        [Enum]::GetNames([System.Security.AccessControl.FileSystemRights]) 


                    $permisos = Read-host "Escriba uno de los permisos que aparece en la lista"

                # Asignar los permisos a la carpeta

                    foreach ($usuario in $NameUser) {

                        foreach ($permiso in $permisos) {
                            
                            # Get-Acl para obtener la lista de permisos actual para la carpeta

                                $acl = Get-Acl $carpeta

                            # New-Object se utiliza para crear un nuevo objeto que representa los permisos que se asignarán al usuario

                                $permisoUsuario = New-Object System.Security.AccessControl.FileSystemAccessRule($usuario, $permiso, "Allow")

                            # SetAccessRule para agregar el nuevo permiso a la lista de permisos de la carpeta

                                $acl.SetAccessRule($permisoUsuario)

                            #Set-Acl para guardar los cambios en la carpeta

                                Set-Acl $carpeta $acl
                        }
                    }

                

                    Write-Host "Los permisos se han configurado correctamente para $carpeta." -ForegroundColor green


                    #Comprobacion

                    (Get-Acl -Path "$carpeta").Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
                
                }

                permisos

            pause;
            break
        }

        3 {
            Clear-Host
            Write-Host "-----------------------------------";
            Write-Host "Informacion del sistema y procesos"; 
            Write-Host "-----------------------------------";

                
                function InfoSitema {
                
                    # Obtener información general del sistema

                        $nombreEquipo = $env:COMPUTERNAME
                        $sistemaOperativo = Get-CimInstance Win32_OperatingSystem
                        $procesador = Get-CimInstance Win32_Processor
                        $memoria = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
                        $espacioDisco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace

                    # Mostrar la información general del sistema

                        Write-Host "Información general del sistema:`n" -ForegroundColor green

                        Write-Host "Nombre del equipo: $nombreEquipo"

                        Write-Host "Sistema operativo: $($sistemaOperativo.Caption) $($sistemaOperativo.Version)"

                        Write-Host "Procesador: $($procesador.Name)"

                        Write-Host "Memoria RAM total: $([math]::Round($memoria.Sum / 1GB,2)) GB"

                        Write-Host "Espacio en disco: $([math]::Round($espacioDisco.FreeSpace / 1GB,2)) GB libres de $([math]::Round($espacioDisco.Size / 1GB,2)) GB"

                    # Obtener información de los procesos en ejecución

                        $procesos = Get-Process | Select-Object Name, CPU, WorkingSet

                    # Mostrar la información de los procesos en ejecución

                        Write-Host "`nInformación de los procesos en ejecución:`n" -ForegroundColor green

                    foreach ($proceso in $procesos) {
                        Write-Host "Proceso: $($proceso.Name) - CPU: $([math]::Round($proceso.CPU,2)) - Memoria RAM: $([math]::Round($proceso.WorkingSet / 1MB,2)) MB"
                    }
                
                
                }


               InfoSitema

            pause;
            break
        }


        4 {
            Clear-Host
            Write-Host "----------------------------";
            Write-Host "Informacion de servicios"; 
            Write-Host "----------------------------";

                function listService {

                    $services = Get-WmiObject -Class Win32_Service

                    foreach ($service in $services) {

                        $serviceName = $service.Name

                        $serviceDisplayName = $service.DisplayName

                        $serviceState = $service.State

                        $serviceDescription = $service.Description

                        $servicePath = $service.PathName
    

                            $salida = @"

                        Service Name: $serviceName
                        Display Name: $serviceDisplayName
                        State: $serviceState
                        Description: $serviceDescription
"@

                        Write-Host "$salida`n"
                    }

                }

                listService



            pause;
            break
        }



         5 {
            Clear-Host
            Write-Host "---------------------------------";
            Write-Host "Informacion para seguridad de red"; 
            Write-Host "---------------------------------`n";

                

                function infoRed {

                    # Comprobar si el firewall está habilitado

                        $firewall = Get-NetFirewallProfile | Where-Object  -Property Enabled -eq "True"

                        if ($firewall) {

                            Write-Host "El firewall está habilitado`n" -ForegroundColor green

                        } else {

                            Write-Host "El firewall está deshabilitado`n" -ForegroundColor green
                        }

                    # Comprobar si hay puertos abiertos

                        $ports =  Get-NetTCPConnection | Where-Object -Property State -eq "Listen"

                        if ($ports) {

                            Write-Host "Hay puertos abiertos en el sistema:" -ForegroundColor green

                            $ports | Format-Table -AutoSize

                        } else {

                            Write-Host "No hay puertos abiertos en el sistema" -ForegroundColor green
                        }


                    # Comprobar si se están utilizando DNS seguros

                        $dns = Get-DnsClientNrptPolicy

                        if ($dns) {

                            Write-Host "Se están utilizando DNS seguros" -ForegroundColor green

                        } else {

                            Write-Host "No se están utilizando DNS seguros" -ForegroundColor green
                        }

                       }

                  infoRed




            pause;
            break
        }



        6 {"Exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Invalid option. Please select another option";pause}
        
    }
 
menu
}


