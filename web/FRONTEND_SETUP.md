# Frontend Development Setup Guide

This guide will help you set up and run the Sherlock frontend for development.

## 📋 Prerequisites

- **Node.js** (version 18 or higher recommended)
- **npm** (comes with Node.js) or **yarn**
- A running Sherlock backend (optional, for full functionality)

## 🚀 Quick Start

### Step 1: Install Dependencies

Navigate to the `web` directory and install dependencies:

```bash
cd web
npm install
```

This will install all required packages including Vue 3, Vite, Quasar, and other dependencies.

### Step 2: Create Environment File (Optional but Recommended)

For standalone frontend development, create a `.env` file in the `web` directory:

```bash
# Create .env file
touch .env
```

Add the following content to `.env`:

```env
VITE_OPENOBSERVE_ENDPOINT=http://localhost:5080/
```

**Optional – use full nav instead of Platform UI:** Platform UI (simplified nav: Logging, Dashboard, Metrics, Alert + slate/blue design) is on by default. To use the original full sidebar and styling, set:
```env
VITE_PLATFORM_UI=false
```
See `ui-guidelines/ui-guidelines.md` for details.

**Note:** If you don't have a backend running, you can still run the frontend, but API calls will fail. The UI will still load and you can see visual changes.

### Step 3: Start Development Server

Run the development server:

```bash
npm run dev
```

The frontend will start on **http://localhost:8081**

You should see output like:
```
  VITE v7.x.x  ready in xxx ms

  ➜  Local:   http://localhost:8081/
  ➜  Network: use --host to expose
```

### Step 4: Open in Browser

Open your browser and navigate to:
```
http://localhost:8081/web/
```

**Important:** Note the `/web/` path - this is required because of the base path configuration.

## 🔥 Hot Module Replacement (HMR)

The development server supports **Hot Module Replacement**, which means:

- ✅ **Changes to Vue components** (.vue files) will update instantly without page refresh
- ✅ **Changes to TypeScript/JavaScript** files will update instantly
- ✅ **Changes to CSS/SCSS** files will update instantly
- ✅ **Changes to images/assets** will update after a quick refresh

**You don't need to manually refresh the page** - changes appear automatically!

## 📝 Making Changes

### Changing Logos

1. Replace logo files in `web/src/assets/images/common/`:
   - `sherlock_logo_light.svg` (light theme)
   - `sherlock_logo_dark.svg` (dark theme)

2. Save the files - the browser will automatically reload

3. Check both light and dark themes to ensure logos look good

### Changing Colors

1. Edit `web/src/styles/quasar-variables.sass`:
   ```sass
   $primary   : #3F7994  // Change this to your brand color
   $secondary : #3da49f  // Change secondary color
   ```

2. Edit `web/src/styles/_variables.scss` for more detailed color customization

3. Save - changes will reflect immediately

### Changing Dashboard Design

1. Edit dashboard components in `web/src/views/Dashboards/`
2. Edit styles in `web/src/styles/app.scss`
3. Save and see changes instantly

## 🛠️ Available Scripts

### Development

```bash
# Start development server (default)
npm run dev

# Start development server for cloud mode
npm run devcloud
```

### Building

```bash
# Build for production
npm run build

# Preview production build locally
npm run preview
```

### Testing

```bash
# Run unit tests
npm run test:unit

# Run unit tests with coverage
npm run test:unit:coverage

# Run end-to-end tests (requires Cypress)
npm run test:e2e:dev
```

### Code Quality

```bash
# Lint and fix code
npm run lint

# Type check (without building)
npm run type-check
```

## 🌐 Development Server Configuration

The dev server is configured in `vite.config.ts`:

- **Port:** 8081 (default)
- **Base Path:** `/web/`
- **Hot Reload:** Enabled by default
- **Source Maps:** Available in dev mode

### Changing the Port

If port 8081 is already in use, you can change it by modifying `vite.config.ts`:

```typescript
server: {
  port: 3000, // Change to your preferred port
},
```

Or run with a custom port:

```bash
npm run dev -- --port 3000
```

## 🔧 Troubleshooting

### Port Already in Use

If you see an error about port 8081 being in use:

```bash
# Option 1: Kill the process using port 8081
lsof -ti:8081 | xargs kill -9

# Option 2: Use a different port
npm run dev -- --port 3000
```

### Dependencies Issues

If you encounter dependency errors:

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Build Errors

If you see TypeScript or build errors:

```bash
# Check for type errors
npm run type-check

# Clear Vite cache
rm -rf node_modules/.vite
npm run dev
```

### Backend Connection Issues

If the frontend can't connect to the backend:

1. Check if backend is running on `http://localhost:5080`
2. Verify `.env` file has correct endpoint:
   ```env
   VITE_OPENOBSERVE_ENDPOINT=http://localhost:5080/
   ```
3. Check browser console for CORS errors

## 📁 Project Structure

```
web/
├── src/
│   ├── assets/          # Images, logos, static assets
│   ├── components/      # Vue components
│   ├── views/           # Page views
│   ├── styles/          # SCSS/CSS files
│   ├── router/          # Vue Router configuration
│   ├── stores/          # Vuex stores
│   └── utils/           # Utility functions
├── public/              # Public assets (favicon, etc.)
├── index.html           # Main HTML entry point
├── vite.config.ts       # Vite configuration
├── package.json         # Dependencies and scripts
└── .env                 # Environment variables (create this)
```

## 🎨 Development Workflow for Rebranding

1. **Start the dev server:**
   ```bash
   cd web
   npm run dev
   ```

2. **Make your changes:**
   - Replace logo files
   - Update colors in SCSS files
   - Modify components

3. **See changes instantly:**
   - Browser auto-reloads
   - No need to rebuild

4. **Test in both themes:**
   - Switch between light/dark mode
   - Verify logos and colors work in both

5. **Build for production (when ready):**
   ```bash
   npm run build
   ```

## 💡 Tips

1. **Use Browser DevTools:**
   - Open DevTools (F12) to see console errors
   - Use React/Vue DevTools extension for component inspection
   - Network tab to debug API calls

2. **Check Both Themes:**
   - The app has light and dark themes
   - Test your rebranding in both modes
   - Logo and color changes should work in both

3. **File Watching:**
   - Vite watches all files in `src/`
   - Changes to any file trigger HMR
   - Large files might take a moment to process

4. **Performance:**
   - Dev server is fast but not optimized
   - Production build (`npm run build`) is optimized
   - Use production build for final testing

## 🔗 Useful Links

- [Vite Documentation](https://vitejs.dev/)
- [Vue 3 Documentation](https://vuejs.org/)
- [Quasar Framework](https://quasar.dev/)
- [TypeScript Documentation](https://www.typescriptlang.org/)

## 📞 Need Help?

- Check browser console for errors
- Check terminal output for build errors
- Verify all dependencies are installed
- Ensure Node.js version is compatible (18+)

---

**Happy Coding! 🚀**
