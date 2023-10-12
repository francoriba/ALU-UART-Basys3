import serial
import serial.tools.list_ports

def main():
    # Listar los puertos serie disponibles
    ports = serial.tools.list_ports.comports()
    portList = []

    print("\nLISTA DE PUERTOS DISPONIBLES:")
    for i, port in enumerate(ports):
        print(f"{i}: {port.device}")
        portList.append(port.device)

    # Solicitar al usuario que seleccione un puerto
    try:
        selected_port_index = int(input("Seleccione el número de puerto: "))
        if 0 <= selected_port_index < len(portList):
            selected_port = portList[selected_port_index]
            print(f"Puerto seleccionado: {selected_port}")
        else:
            print("Selección de puerto fuera de rango.")
            return
    except ValueError:
        print("Entrada no válida. Debe ingresar un número válido.")
        return

    # Configurar la conexión serie
    serialInst = serial.Serial(selected_port, baudrate=9600)  # Selecciona el puerto y la velocidad de baudios

    continue_flag = True

    while continue_flag:
        try:
            # Envío de datos
            data_A = input("Operando A: ")
            data_B = input("Operando B: ")
            opcode = input("Opcode: ")

            # Enviar los datos
            serialInst.write(data_A.encode())
            serialInst.write(data_B.encode())
            serialInst.write(opcode.encode())

            # Leer respuesta
            response = serialInst.read(1).decode()

            print(f"Respuesta recibida: {response}")

            # Preguntar si se desea repetir el proceso
            repeat = input("¿Desea hacer otra operación? (y/n): ")
            if repeat.lower() != 'y':
                continue_flag = False
        except KeyboardInterrupt:
            print("\nPrograma detenido por el usuario.")
            continue_flag = False
        except Exception as e:
            print("Ocurrió un error:", str(e))

    # Cerrar el puerto serie al salir
    serialInst.close()

if __name__ == "__main__":
    main()
