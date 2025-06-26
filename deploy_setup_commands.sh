
#!/bin/bash

echo "🔧 Setting up the environment..."

echo "🔢 Incrementing APP_VERSION in .env..."

if [ -f .env ]; then
    # Extract current version
    current_version=$(grep "^APP_VERSION=" .env | cut -d '"' -f2)

    if [[ $current_version =~ ^([0-9]+)\.([0-9]+)$ ]]; then
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        new_minor=$((minor + 1))
        new_version="${major}.${new_minor}"

        # Replace version in .env
        sed -i "s/^APP_VERSION=\"${current_version}\"/APP_VERSION=\"${new_version}\"/" .env

        echo "✅ APP_VERSION updated: $current_version → $new_version"
    else
        echo "⚠️ Could not parse APP_VERSION format: '$current_version'"
    fi
else
    echo "❌ .env file not found."
fi

if [ -f artisan ]; then
    echo "🔁 Clear site cache..."
    php artisan o:clear
fi

echo "✅ Setup complete."
