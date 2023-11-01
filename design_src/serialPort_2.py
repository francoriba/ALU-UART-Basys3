import sys
import serial
import serial.tools.list_ports

continuar = True
BAUDRATE = 19200  # Establece la velocidad de baudios para esta comunicación

OPCODES = {
    'ADD': 0x20,
    'SUB': 0x22,
    'AND': 0x24,
    'OR': 0x25,
    'XOR': 0x26,
    'NOR': 0x27,
    'SRA': 0x03,
    'SRL': 0x020
}

class SerialPortControl:
    def __init__(self, port):
        self.serial_port = serial.Serial(port, BAUDRATE, timeout=1)

    def get_crc(self, data):
        return data ^ 0xFF

    def send_serial_data(self):
        operand1_hex = input('Operando 1 (Hex): ')
        operand2_hex = input('Operando 2 (Hex): ')
        operation = input('Seleccione la Operación (ADD, SUB, AND, OR, XOR, NOR, SRA, SRL): ')

        if operation not in OPCODES:
            print('Operación no válida')
            return

        operand1 = int(operand1_hex, 16)
        operand2 = int(operand2_hex, 16)
        selected_operation = OPCODES[operation]

        # Calcula un byte de CRC (no se utiliza, pero se envía)
        crc = self.get_crc(selected_operation ^ operand1 ^ operand2)

        # Envía un byte adicional para el CRC (no se utiliza en el módulo Interface)
        data_to_send = bytes([selected_operation, operand1, operand2, crc])
        self.serial_port.write(data_to_send)

        received_data = self.serial_port.read(1)
        if len(received_data) == 1:
            result = int.from_bytes(received_data, byteorder='big')
            print('Resultado:', hex(result))
        else:
            print('Error de recepción: No se recibieron los datos correctamente')

def select_serial_port():
    ports = serial.tools.list_ports.comports()
    portList = []

    print("\nLISTA DE PUERTOS DISPONIBLES:")
    for i, port in enumerate(ports):
        print(f"{i}: {port.device}")
        portList.append(port.device)
    try:
        selected_port_index = int(input("Seleccione el número de puerto: "))
        if 0 <= selected_port_index < len(portList):
            selected_port = portList[selected_port_index]
            print(f"Puerto seleccionado: {selected_port}")
            return selected_port
        else:
            print("Selección de puerto fuera de rango.")
            return None
    except ValueError:
        print("Entrada no válida. Debe ingresar un número válido.")
        return None

if __name__ == "__main__":
    selected_port = select_serial_port()
    if selected_port:
        app = SerialPortControl(selected_port)
        while continuar:
            app.send_serial_data()
            response = input('¿Nueva operación? y/n: ')
            if response == 'y' or response == 'Y':
                continuar = True
            if response == 'n' or response == 'N':
                continuar = False
