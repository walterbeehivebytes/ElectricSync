# Deploying ElectricSync to GitHub Pages

This guide will help you deploy the ElectricSync Flutter web app to GitHub Pages.

## Prerequisites

- GitHub account
- Git installed locally
- Flutter installed locally

## Deployment Options

### Option 1: Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically deploys when you push to the `main` branch.

#### Steps:

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Add authentication and deployment workflow"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Click **Settings** → **Pages** (left sidebar)
   - Under **Source**, select **Deploy from a branch**
   - Select branch: **gh-pages**
   - Select folder: **/ (root)**
   - Click **Save**

3. **Wait for deployment:**
   - Go to **Actions** tab in your repository
   - Watch the "Deploy to GitHub Pages" workflow
   - Once complete (green checkmark), your app is live!

4. **Access your app:**
   - Your app will be available at: `https://YOUR-USERNAME.github.io/ElectricSync/`
   - Or check the GitHub Pages section in Settings for the exact URL

### Option 2: Manual Deployment

If you prefer to deploy manually:

1. **Build the web app:**
   ```bash
   cd frontend
   flutter build web --release --base-href /ElectricSync/
   ```

2. **Install gh-pages package (if not already installed):**
   ```bash
   npm install -g gh-pages
   ```

3. **Deploy to gh-pages branch:**
   ```bash
   cd build/web
   git init
   git add .
   git commit -m "Deploy to GitHub Pages"
   git branch -M gh-pages
   git remote add origin https://github.com/YOUR-USERNAME/ElectricSync.git
   git push -f origin gh-pages
   ```

4. **Enable GitHub Pages** (same as Option 1, step 2)

## Updating the Deployment

### Automatic Updates:
Just push to main branch:
```bash
git add .
git commit -m "Your update message"
git push origin main
```

The GitHub Action will automatically rebuild and deploy.

### Manual Updates:
Rebuild and redeploy:
```bash
cd frontend
flutter build web --release --base-href /ElectricSync/
# Then follow manual deployment steps above
```

## Troubleshooting

### App shows blank page:
- Check that `--base-href` matches your repository name
- If your repo is named differently, update the workflow file:
  ```yaml
  run: flutter build web --release --base-href /YOUR-REPO-NAME/
  ```

### GitHub Actions failing:
- Check the Actions tab for error logs
- Ensure Flutter version in workflow matches your local version
- Verify all dependencies in `pubspec.yaml` are properly listed

### 404 errors on refresh:
- This is normal for single-page apps on GitHub Pages
- Users should use the app's navigation instead of browser refresh
- Or implement a custom 404.html redirect (advanced)

## Demo Accounts

Your deployed app will have these test accounts:
- **Foreman**: `foreman@esync.com` / `password123`
- **Journeyman**: `journeyman@esync.com` / `password123`
- **Electrician**: `electrician@esync.com` / `password123`

## Custom Domain (Optional)

To use a custom domain:

1. Add a `CNAME` file to `frontend/web/` with your domain:
   ```
   yourdomain.com
   ```

2. Update the workflow to not override CNAME:
   ```yaml
   cname: yourdomain.com
   ```

3. Configure DNS with your domain provider:
   - Add a CNAME record pointing to: `YOUR-USERNAME.github.io`

## Security Notes

⚠️ **Important:** This is currently a frontend-only app with mock authentication.

For production use, you'll need:
- Real backend API for authentication
- Secure database for user data
- HTTPS (GitHub Pages provides this automatically)
- Environment variables for API keys (don't commit secrets!)
- Real task/project data storage

## Next Steps for Production

1. **Backend Setup:**
   - Set up a backend API (Node.js, Python, Go, etc.)
   - Implement real authentication (JWT, OAuth)
   - Database (PostgreSQL, MongoDB, etc.)

2. **Deploy Backend:**
   - Heroku, Railway, Render, or AWS
   - Update Flutter app to call your API endpoints

3. **Replace Mock Data:**
   - Update `AuthService` to call real API
   - Implement proper state management (Provider, Riverpod, Bloc)
   - Add secure token storage

4. **CI/CD:**
   - The GitHub Actions workflow is already set up for frontend
   - Add similar workflows for your backend when ready

## Support

For issues or questions:
- Check GitHub Actions logs in the Actions tab
- Review Flutter web docs: https://flutter.dev/web
- Check GitHub Pages docs: https://docs.github.com/pages
