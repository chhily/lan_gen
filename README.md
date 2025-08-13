# Flutter JSON Localization Generator

A powerful desktop tool designed to streamline localization for your Flutter projects. Generate JSON files for the `easy_localization` package directly from a single Excel file, eliminating manual editing and saving you valuable development time.

## 🚀 Key Features

* **📂 Direct Excel Import**: Instantly load all your app's translations from a single `.xlsx` file.
* **✍️ Smart Merge Mode**: Update existing JSON files without losing your current translations. Only new or modified keys are changed.
* **👀 Preview**: See your translations in a clean table view before you export.
* **⚠️ Duplicate Key Detection**: Automatically flags duplicate keys within each language to prevent errors.
* **💾 Persistent Export Path**: Set your export folder once, and the app remembers it for all future uses.
* **✨ Clean & Simple UI**: An intuitive interface that makes localization a breeze.
* **🗑️ One-Click Clear**: Reset the imported data with a single click to start fresh.

## 📚 Getting Started

### 1. Prepare Your Excel File

Your Excel sheet is the single source of truth. The structure is simple:

* The **first column** must be named `key`.
* Every other column header is treated as a **language code** (e.g., `en`, `de`, `fr`).

**Example** `translations.xlsx`:

| **key** | **en** | **es** | **fr** |
|---------|---------|---------|---------|
| `welcomeMessage` | Welcome! | ¡Bienvenido! | Bienvenue! |
| `goodbyeMessage` | Goodbye | Adiós | Au revoir |
| `loginButton` | Login | Iniciar Sesión | Connexion |

*Note: Empty cells are fine! They will be converted to empty strings in the JSON output.*

### 2. The Workflow

1. **Pick File**: Click `Pick File` and select your `.xlsx` translation file.
2. **Preview Data**: The app will instantly parse and display the keys and translations.
3. **Choose Export Location**: The first time, select a destination folder for your JSON files (e.g., `your_flutter_project/assets/translations`). This path will be saved for next time.
4. **Export**: Click `Export`. The tool generates a separate `.json` file for each language.

### 3. Generated Files

If you export to a folder named `assets/translations`, the tool will generate:

```
/assets/translations
├── en.json
├── es.json
└── fr.json
```

**Example** `en.json`:

```json
{
  "welcomeMessage": "Welcome!",
  "goodbyeMessage": "Goodbye",
  "loginButton": "Login"
}
```

## 🔗 Integrating with `easy_localization`

### 1. Add Assets to `pubspec.yaml`

Make sure your Flutter project knows where to find the generated files.

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/translations/
```


