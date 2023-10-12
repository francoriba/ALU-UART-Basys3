import serial
import serial.tools.list_ports

# Listar los puertos serie disponibles
ports = serial.tools.list_ports.comports()
portList = []
continue_flag = True

print("\nLISTA DE PUERTOS DISPONIBLES:")
for onePort in ports:
    portList.append(str(onePort))
    print("\t" + str(onePort) + "\n")

# Solicitar al usuario que seleccione un puerto
val = input("Seleccione el número de puerto (ttyUSB en Linux o COM en Windows): ")

portVar = None

# Buscar el puerto seleccionado
for x in range(len(portList)):
    if portList[x].startswith("COM" + str(val)):
        portVar = "COM" + str(val)
        print("\tPuerto seleccionado: " + portList[x])
    elif portList[x].startswith("/dev/ttyUSB" + str(val)):
        portVar = "/dev/ttyUSB" + str(val)
        print("\tPuerto seleccionado: " + portList[x])

# Verificar si se encontró un puerto válido
if portVar is None:
    print("El puerto seleccionado no es válido.")
else:
    # Configurar la conexión serie
    serialInst = serial.Serial()
    serialInst.baudrate = 9600 #19200 #9600
    serialInst.port = portVar
    serialInst.parity = serial.PARITY_NONE

    continue_flag = True

    try:
        # Abrir el puerto serie
        serialInst.open()

        # Bucle para enviar datos ingresados por el usuario
        while continue_flag:

            data = int(input("Operando A: "))
            #serialInst.write(data.encode())  # Enviar datos al puerto serie en formato bytes
            serialInst.write(data.to_bytes(1, byteorder='little'))  # Enviar datos como un byte


            data = int(input("Operando B: "))
            #serialInst.write(data.encode())  # Enviar datos al puerto serie en formato bytes
            serialInst.write(data.to_bytes(1, byteorder='little'))  # Enviar datos como un byte


            data = int(input("Opcode: "))
            #serialInst.write(data.encode())  # Enviar datos al puerto serie en formato bytes
            serialInst.write(data.to_bytes(1, byteorder='little'))  # Enviar datos como un byte
        

            # Preguntar si se desea repetir el proceso
            repeat = input("¿Desea hacer otra operación? (y/n): ")
            if repeat.lower() != 'y':
                continue_flag = False
    except KeyboardInterrupt:
            print("\nPrograma detenido por el usuario.")
            continue_flag = False
    except Exception as e:
            print("Ocurrió un error:", str(e))

