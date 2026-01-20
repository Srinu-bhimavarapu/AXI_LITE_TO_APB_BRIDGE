# AXI-Lite to APB Bridge – SystemVerilog RTL

## 📌 Project Overview

This project implements an **AXI-Lite to APB Bridge** using **SystemVerilog RTL**.
The bridge enables an **AXI-Lite master** to access **APB-based peripherals** by translating AXI-Lite read/write transactions into the corresponding APB protocol phases.

This design reflects a **real SoC control-path component**, commonly used to connect low-speed peripherals (UART, SPI, GPIO, Timers) to an AXI-based system.

This is a **non-dummy, protocol-focused project**, suitable for **RTL Design / SoC / VLSI internships**.

---

## 🧠 Key Features

* Fully synthesizable **SystemVerilog RTL**
* Supports **AXI-Lite Read and Write transactions**
* Converts AXI-Lite protocol to **APB master protocol**
* FSM-based protocol control
* Clean handling of APB SETUP and ENABLE phases
* Proper AXI-Lite response generation (`BRESP`, `RRESP`)
* Modular and extendable bridge design

---

## 🏗️ Bridge Architecture (High-Level)

### Protocol Translation

```text
AXI-Lite Slave Interface
        ↓
   Control FSM
        ↓
   APB Master Interface
```

### Supported Transactions

* AXI-Lite Write → APB Write
* AXI-Lite Read  → APB Read

---

## 🔌 Interfaces Implemented

### AXI-Lite Slave Interface

* Write Address: `AWADDR`, `AWVALID`, `AWREADY`
* Write Data: `WDATA`, `WVALID`, `WREADY`
* Write Response: `BRESP`, `BVALID`, `BREADY`
* Read Address: `ARADDR`, `ARVALID`, `ARREADY`
* Read Data: `RDATA`, `RRESP`, `RVALID`, `RREADY`

### APB Master Interface

* Address: `PADDR`
* Control: `PSEL`, `PENABLE`, `PWRITE`
* Data: `PWDATA`, `PRDATA`
* Handshake: `PREADY`
* Error: `PSLVERR`

---

## 🔁 Finite State Machine (FSM)

### FSM States

```text
IDLE → APB_SETUP → APB_ENABLE → AXI_RESP → IDLE
```

### State Description

| State      | Description                                   |
| ---------- | --------------------------------------------- |
| IDLE       | Waits for AXI-Lite read or write request      |
| APB_SETUP  | Asserts `PSEL`, prepares APB transfer         |
| APB_ENABLE | Asserts `PENABLE`, waits for `PREADY`         |
| AXI_RESP   | Sends AXI-Lite response (`BVALID` / `RVALID`) |

---

## 🔄 Transaction Flow

### AXI-Lite Write

1. Detects `AWVALID && WVALID`
2. Captures address and write data
3. Performs APB SETUP and ENABLE phases
4. Waits for `PREADY`
5. Returns `BVALID` with `BRESP`

### AXI-Lite Read

1. Detects `ARVALID`
2. Captures read address
3. Performs APB SETUP and ENABLE phases
4. Samples `PRDATA`
5. Returns `RVALID` with `RDATA` and `RRESP`

---

## ⚙️ Design Highlights

* Single FSM controlling both read and write paths
* Address and data registered for stable APB access
* Correct APB timing: SETUP → ENABLE
* AXI-Lite response generation based on `PSLVERR`
* No latch inference
* No combinational loops
* Fully synthesizable RTL

---

## ⚠️ AXI-Lite Simplifications (Intentional)

For clarity and learning purposes:

* Assumes `AWVALID` and `WVALID` are asserted together
* Optional AXI-Lite signals not implemented:

  * `WSTRB`
  * `AWPROT`
* Single outstanding transaction supported

> These can be extended easily for full AXI-Lite compliance.

---

## 📂 Repository Structure

```text
src/
└── axi_lite_to_apb_bridge.sv

testbench/
└── axi_lite_to_apb_bridge_tb.sv   (if present)
```

---

## 🚀 Deployment & Simulation Guide

### 🧰 Prerequisites

**Simulator**

* Xilinx Vivado (recommended)
* Questa / ModelSim
* Synopsys VCS

**OS**

* Linux or Windows

**Knowledge**

* SystemVerilog
* AXI-Lite and APB protocols

---

### 📥 Step 1: Clone the Repository

```bash
git clone https://github.com/Srinu-bhimavarapu/AXI_LITE_TO_APB_BRIDGE.git
cd AXI_LITE_TO_APB_BRIDGE
```

---

### ▶️ Step 2: Run Simulation (Vivado)

#### GUI Method

1. Open **Vivado**
2. Create a new **RTL Project**
3. Add RTL files from `src/`
4. Add testbench files from `testbench/`
5. Set testbench as simulation top
6. Run **Behavioral Simulation**

#### Tcl Flow

```tcl
read_verilog src/axi_lite_to_apb_bridge.sv
read_verilog testbench/*.sv
launch_simulation
```

---

## 🔍 Waveform Verification Checklist

Verify:

* AXI-Lite `AWREADY / WREADY / ARREADY` behavior in IDLE
* APB `PSEL` assertion in SETUP phase
* APB `PENABLE` assertion in ENABLE phase
* `PREADY` driven completion
* Correct `BVALID` / `RVALID` responses
* Proper `BRESP` / `RRESP` based on `PSLVERR`

---

## 🧪 Verification Status

* Directed SystemVerilog testbench
* Functional protocol validation
* Waveform-based checking

---

## 🎯 Learning Outcomes

* AXI-Lite to APB protocol translation
* FSM-based bus bridging design
* Control-path focused RTL design
* Practical SoC peripheral integration
* Debugging bus protocols using waveforms

---

## 📌 Future Enhancements

* Add `WSTRB` support
* Support multiple APB slaves (decoder)
* Improve AXI-Lite compliance
* Add UVM-based verification
* Integrate into full AXI-based SoC

---

## 👤 Author

**Srinu Bhimavarapu**
Electronics & Communication Engineering
Focus Areas: RTL Design, AXI/APB Protocols, SoC Architecture

---

## ⭐ Recruiter Note

✔ Hand-written RTL
✔ Protocol-aware AXI–APB bridge
✔ FSM-based control
✔ Simulation-validated

This project demonstrates **strong understanding of control-path design and bus protocol bridging**, a key skill for **SoC and RTL design roles**.
