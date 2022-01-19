import "./src/styles/global.css"

window.dataLayer = window.dataLayer || [];

function gtag() { dataLayer.push(arguments) };

gtag('consent', 'default', {
    'ad_storage': 'denied',
    'analytics_storage': 'denied',
    'region': ['BE', 'BG', 'CZ', 'DK', 'DE', 'EE', 'IE', 'GR', 'ES', 'FR', 'HR', 'IT', 'CY', 'LV', 'LT', 'LU', 'HU', 'MT', 'NL', 'AT', 'PL', 'PT', 'RO', 'SI', 'SK', 'FI', 'SE', 'US-CA']
});

gtag('consent', 'default', {
    'ad_storage': 'granted',
    'analytics_storage': 'granted'
});

