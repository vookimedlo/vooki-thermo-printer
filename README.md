# 🖨️ VookiThermoPrinter

**A lightweight macOS tool for printing to Niimbot label printers.**

VookiThermoPrinter is a native macOS application designed for creating and printing labels on **Niimbot D110 (DPI 203)** and **Niimbot D11_H (DPI 300)** printers.  
It includes a simple built-in label editor, a label database, and uses **private CloudKit** for syncing saved labels and print history.  
Communication with the printers is handled via **Bluetooth Low Energy (BLE)**.

---

## ✨ Features

- 🧾 **Bluetooth LE printing** – direct connection to Niimbot printers  
- 🖋️ **Lightweight label editor** – create and modify labels quickly  
- ☁️ **Private CloudKit sync** – stores saved labels and history securely  
- 📦 **Built-in label database** – predefined label formats and sizes  
- 🧱 **Multiple printer builds** – separate apps for D110 and D11_H  
- 🧃 **DMG distribution** – simple installation (Homebrew formula coming soon)

---

## 🏷️ Supported Labels

| EAN | Size (mm) | Label Type | Color | Note |
|-----|------------|-------------|--------|------|
| 6972842743589 | 30×15 | With gaps | white |  |
| 6971501224599 | 30×15 | With gaps | white |  |
| 02282280 | 30×15 | With gaps | white | came with printer |
| 6971501224568 | 30×12 | With gaps | white |  |
| 6972842743565 | 30×12 | With gaps | white |  |
| 6971501224582 | 26×15 | With gaps | white |  |
| 6971501224605 | 50×15 | With gaps | white |  |
| 6971501224551 | 22×12 | With gaps | white |  |
| 6972842743558 | 22×12 | With gaps | white |  |
| 10252110 | 75×12 | With gaps | white |  |
| 6972842743787 | 109×12.5 | With gaps | white | cable – 12.5×74 + 7×35 |
| 6972842743824 | 109×12.5 | With gaps | yellow | cable – 12.5×74 + 7×35 |
| 6972842743817 | 109×12.5 | With gaps | red | cable – 12.5×74 + 7×35 |
| 6972842743800 | 109×12.5 | With gaps | green | cable – 12.5×74 + 7×35 |
| 6972842743794 | 109×12.5 | With gaps | blue | cable – 12.5×74 + 7×35 |
| 6971501229778 | 30×12 | With gaps | white |  |
| 01222281 | 40×12 | With gaps | white | came with printer [D11_H] |

> ⚠️ Supported label types: **With gaps** and **Transparent**  
> Other label types are not supported by Niimbot D110 or D11_H printers.

---

### 🧩 Label Type Explanation

- **With gaps** – Standard paper or plastic labels with small spacing between each label.  
  The printer detects the gaps optically to align each print correctly.  
- **Transparent** – Clear or semi-transparent labels that use a special sensing mode.  
  These require careful alignment during printing to avoid misfeeds.

When reporting or adding new labels, please ensure the **Label Type** matches one of these two categories.

---

## 🧾 Missing a Label?

If your label type is **not yet included in the database**, please report it by opening a  
👉 [**GitHub Issue – Missing Label Report**](../../issues/new?template=missing_label.md)

Provide the EAN, size, label type, color, and any additional notes.  
Your contribution helps improve the compatibility of the app for everyone.

---

## 🧩 Installation

Currently available as DMG builds:

- `VookiThermoPrinter-D110.dmg`
- `VookiThermoPrinter-D11_H.dmg`

Future versions will support installation via **Homebrew**.  
Instructions will be added once the formulae are published.

---

## ⚙️ Build Outputs

| Application | Printer | DPI | Platform |
|--------------|----------|-----|-----------|
| `VookiThermoPrinter-D110` | Niimbot D110 | 203 | macOS |
| `VookiThermoPrinter-D11_H` | Niimbot D11_H | 300 | macOS |

---

## 👨‍💻 Author

Created by **Michal Duda**  
💡 Contributions are welcome!

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.  
See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

Special thanks to the project **[niimbluelib](https://printers.niim.blue/)**  
for providing an excellent reference implementation and documentation for Niimbot printer communication.