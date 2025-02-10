


# GSHELL <img src="https://github.com/ShreyashVaidya11/termux-cloudshell-setup/blob/main/Assets/InShot_20250210_132012306.jpg" alt="Termux" align="right"> 

![GSHELL Demo](https://via.placeholder.com/800x400.png?text=GSHELL+Demo+GIF+Here) 


A seamless bridge between Termux and Google Cloud Shell 🔄

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/ShreyashVaidya11/termux-cloudshell-setup/pulls)
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Open Source? Yes!](https://badgen.net/badge/Open%20Source%20%3F/Yes%21/blue?icon=github)](https://github.com/Naereen/badges/)
[![GitHub version](https://badge.fury.io/gh/Naereen%2FStrapDown.js.svg)](https://github.com/Naereen/StrapDown.js)
## Termux Project

[![Termux Compatible](https://img.shields.io/badge/Termux-Compatible-green?style=for-the-badge&logo=termux)](https://f-droid.org/en/packages/com.termux/)

## 🌟 Features

- **One-Click Setup**  
  ![Setup Animation](https://via.placeholder.com/400x200.png?text=Installation+Progress+Animation)  
  Fully automated environment configuration

- **Secure Containerization**  
  🛡️ Isolated Ubuntu environment using proot-distro

- **Cloud Power in Your Pocket**  
  📱 Access Google Cloud SDK directly from mobile

- **Interactive UI**  
  ![UI Demo](https://via.placeholder.com/400x200.png?text=Animated+Spinners+and+Bars)  
  Real-time progress indicators and visual feedback

## 🚀 Quick Start

### Prerequisites
- Android Device (7.0+ recommended)
- Termux App ([Download from F-Droid](https://f-droid.org/en/packages/com.termux/))

### Installation

```bash
# Clone repository
git clone https://github.com/ShreyashVaidya11/termux-cloudshell-setup.git

# Navigate to directory
cd gshell

# Make script executable
chmod +x gshell.sh

# Full installation
./gshell.sh
```

### Direct Access
```bash
./gshell.sh -direct
```


## 📂 Project Structure
```
gshell/
├── assets/
│   ├── demo.gif
│   ├── screenshot1.png
│   └── screenshot2.png
├── gshell.sh
├── LICENSE
└── README.md
```

## 🛠️ Technical Overview

```mermaid
graph TD
    A[Termux] --> B{GSHELL Script}
    B --> C[Update Packages]
    B --> D[Install Dependencies]
    B --> E[Create Ubuntu Container]
    E --> F[Install Cloud SDK]
    F --> G[Launch Cloud Shell]
```

## 🤝 Contributing

Contributions are welcome! Please follow our [contribution guidelines](CONTRIBUTING.md).

