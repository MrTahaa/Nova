# Nova

Nova is a Flutter app built to wake computers on the local network remotely with Wake-on-LAN. The app stores your device list on the phone, checks each device by MAC address and IP address, and tries to wake a powered-off computer by sending a magic packet when the network setup is correct.

## How the app works

1. Create a device entry in the app.
2. For each entry, enter the device name, MAC address, and IP address.
3. Nova first checks the saved device with a ping.
4. If the device is reachable for wake-up, it sends a Wake-on-LAN magic packet.
5. After the computer starts, it pings again and updates the online status.

For the app to work correctly, some settings must be configured on the computer, network adapter, and BIOS or UEFI side.

## Required BIOS settings

Open your computer's BIOS or UEFI settings and check the following options:

- ErP Ready: set to Disabled.
- Power On By PCI-E: set to Enabled.

These settings are important so the network card can still receive a wake signal while the computer is powered off.

## Windows Device Manager settings

Windows needs to allow the network adapter to wake the machine:

1. Right-click Start and open Device Manager.
2. Expand the Network adapters list.
3. Right-click Realtek PCIe GbE Family Controller and open Properties.
4. In the Power Management tab, enable these options:
	- Allow the computer to turn off this device to save power.
	- Allow this device to wake the computer.
	- Only allow a magic packet to wake the computer.
5. Go to the Advanced tab and enable these options:
	- Wake on Magic Packet
	- Shutdown Wake-On-Lan or Shutdown Wake on LAN

## Windows Power Options and Fast Startup

If Fast Startup is enabled in Windows, the computer may not fully shut down and the WoL packet may not work reliably:

1. Go to Control Panel > Hardware and Sound > Power Options.
2. Click the Choose what the power buttons do link on the left.
3. Click Change settings that are currently unavailable at the top.
4. Uncheck Turn on fast startup at the bottom.
5. Save the changes.

## How to find the MAC address

The MAC address is the physical address of the network adapter and is required for every device in the app.

### On Windows

1. Type cmd in the Start menu and open Command Prompt.
2. Run this command:

	ipconfig /all

3. Find the Physical Address line under the network adapter you are using.
4. Enter it in the AA:BB:CC:DD:EE:FF format.

### Alternative method

- You can also check the physical address from Device Manager > Network adapters > the relevant adapter > Status or Details.
- The MAC address may also appear in the connected devices list in your modem or router interface.

## How to find the IP address

Because the app checks the device with ping, the correct local IP address is required.

### On Windows

1. Open Command Prompt.
2. Run this command:

	ipconfig

3. Take the IPv4 Address line from the adapter you are using.
4. It is usually a local network address such as 192.168.x.x or 10.x.x.x.

### Things to keep in mind

- If the computer's IP address changes often, it is better to create a DHCP reservation in the router.
- The phone and the target computer must be on the same local network.
- The IP address entered in the app must be the device's current local IP address.

## Quick usage summary

- First enable WoL support in the BIOS.
- Enable the wake options in the Windows network adapter settings.
- Turn off Fast Startup.
- Add the correct MAC address and local IP address.
- Then try waking the device from Nova.

## Note

This project works within the local network. Waking a device from outside the network may require router forwarding, a static IP address, and additional network settings.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for the full text.
