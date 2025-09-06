#!/usr/bin/env bash

### auto-tune-dump commands BEGIN

### VM writeback timeout
echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';

### Enable Audio codec power management
echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';

### Autosuspend for USB device USB 10/100/1G/2.5G LAN [Realtek]
echo 'auto' > '/sys/bus/usb/devices/2-2.1/power/control';

### auto-tune-dump commands END

pci_ids=(
	00:00.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Root Complex
	00:00.2 #        IOMMU: Advanced Micro Devices, Inc. [AMD] Phoenix IOMMU
	00:01.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Host Bridge
	# 00:01.1 # PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix GPP Bridge
	00:01.2 #   PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix GPP Bridge
	00:02.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Host Bridge
	# 00:02.2 # PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix GPP Bridge
	00:02.3 #   PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix GPP Bridge
	00:03.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Host Bridge
	# 00:03.1 # PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 19h USB4/Thunderbolt PCIe tunnel
	00:04.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Host Bridge
	00:08.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Host Bridge
	# 00:08.1 # PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Internal GPP Bridge to Bus [C:A]
	00:08.2 #   PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Internal GPP Bridge to Bus [C:A]
	# 00:08.3 # PCI bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Internal GPP Bridge to Bus [C:A]
	00:14.0 #        SMBus: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller (rev 71)
	00:14.3 #   ISA bridge: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge (rev 51)

	00:18.0 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 0
	00:18.1 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 1
	00:18.2 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 2
	00:18.3 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 3
	00:18.4 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 4
	00:18.5 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 5
	00:18.6 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 6
	00:18.7 #  Host bridge: Advanced Micro Devices, Inc. [AMD] Phoenix Data Fabric; Function 7
	
	01:00.0 # VGA compatible controller: NVIDIA Corporation AD107M [GeForce RTX 4060 Max-Q / Mobile] (rev a1)
	# 01:00.1 # Audio device: NVIDIA Corporation AD107 High Definition Audio Controller (rev a1)

	02:00.0 # Non-Volatile memory controller: Sandisk Corp WD PC SN810 / Black SN850 NVMe SSD (rev 01)
	03:00.0 # Network controller: MEDIATEK Corp. MT7922 802.11ax PCI Express Wireless Network Adapter
	04:00.0 # SD Host controller: Genesys Logic, Inc GL9750 SD Host Controller (rev 01)

	64:00.0 # VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Phoenix1 (rev c2)
	# 64:00.1 # Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Radeon High Definition Audio Controller [Rembrandt/Strix]
	64:00.2 # Encryption controller: Advanced Micro Devices, Inc. [AMD] Phoenix CCP/PSP 3.0 Device
	# 64:00.3 # USB controller: Advanced Micro Devices, Inc. [AMD] Device 15b9
	# 64:00.4 # USB controller: Advanced Micro Devices, Inc. [AMD] Device 15ba
	# 64:00.5 # Multimedia controller: Advanced Micro Devices, Inc. [AMD] Audio Coprocessor (rev 63)
	64:00.6 # Audio device: Advanced Micro Devices, Inc. [AMD] Family 17h/19h/1ah HD Audio Controller
	65:00.0 # Non-Essential Instrumentation [1300]: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Function
	66:00.0 # Non-Essential Instrumentation [1300]: Advanced Micro Devices, Inc. [AMD] Phoenix Dummy Function
	# 66:00.3 # USB controller: Advanced Micro Devices, Inc. [AMD] Device 15c0
	# 66:00.4 # USB controller: Advanced Micro Devices, Inc. [AMD] Device 15c1
	# 66:00.5 # USB controller: Advanced Micro Devices, Inc. [AMD] Pink Sardine USB4/Thunderbolt NHI controller #1
)

for id in "${pci_ids[@]}"; do
	echo 'auto' > "/sys/bus/pci/devices/0000:${id}/power/control";
done
