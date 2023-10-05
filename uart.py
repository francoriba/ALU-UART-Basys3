import serial
import serial.tools.list_ports

# Listar los puertos serie disponibles
ports = serial.tools.list_ports.comports()
portList = []

print("\nLISTA DE PUERTOS DISPONIBLES:")
for onePort in ports:
    portList.append(str(onePort))
    print("\t" + str(onePort) + "\n")

# Solicitar al usuario que seleccione un puerto
val = input("Seleccione el número de puerto (ttsyUSB en Linux o COM en Windows): ")

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
    serialInst.baudrate = 9600
    serialInst.port = portVar

    try:
        # Abrir el puerto serie
        serialInst.open()

        # Bucle para leer y mostrar datos en tiempo real
        while True:
            packet = serialInst.read()  # Leer un byte del puerto serie
            int_val = int.from_bytes(packet, "big")  # Convertir a valor entero
            char_val = chr(int_val)  # Convertir a carácter ASCII
            print(char_val, end='')  # Mostrar el carácter en la consola sin nueva línea

    except KeyboardInterrupt:
        print("\nPrograma detenido por el usuario.")
    except Exception as e:
        print("Ocurrió un error:", str(e))
    finally:
        # Cerrar el puerto serie al salir
        serialInst.close()
