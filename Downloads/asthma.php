<?php
require_once __DIR__ . '/tracker-capi.php';
$config = tracker_get_config();
$angle = 'asthma';
$requested_acc = $_GET['acc'] ?? null;
$account = tracker_get_account($angle, $requested_acc);
$active_pixel_id = $account['pixel_id'] ?? '2158442291415844';
$active_acc_key = $account['key'] ?? ($angle . '_main');

// Save the active account tag and Meta fbclid in 30-day first-party cookies for Thank You page
if (!headers_sent()) {
    setcookie('respira_acc_' . $angle, $active_acc_key, time() + (86400 * 30), '/');
    setcookie('respira_last_angle', $angle, time() + (86400 * 30), '/');
    if (!empty($_GET['fbclid'])) {
        setcookie('respira_fbclid', $_GET['fbclid'], time() + (86400 * 30), '/');
        $fbc_creation_ms = (string)round(microtime(true) * 1000);
        setcookie('_fbc', 'fb.1.' . $fbc_creation_ms . '.' . $_GET['fbclid'], time() + (86400 * 90), '/');
    }
}

// SERVER-SIDE CAPI PAGEVIEW EVENT (with Deduplication Event ID)
$pv_event_id = tracker_generate_event_id($angle, 'pv');
if (!empty($active_pixel_id) && !empty($account['access_token'])) {
    tracker_send_capi_event(
        $active_pixel_id,
        $account['access_token'],
        'PageView',
        $pv_event_id,
        [],
        $account['test_code'] ?? null,
        $angle,
        $active_acc_key
    );
}
?>
﻿<!DOCTYPE html>
<html lang="en-US">

<head>
    <!-- Meta Pixel Code (Dynamic) -->
    <script>
        !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
        n.callMethod.apply(n,arguments):n.queue.push(arguments)};
        if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
        n.queue=[];t=b.createElement(e);t.async=!0;
        t.src=v;s=b.getElementsByTagName(e)[0];
        s.parentNode.insertBefore(t,s)}(window, document,'script',
        'https://connect.facebook.net/en_US/fbevents.js');
        fbq('init', '<?php echo htmlspecialchars($active_pixel_id); ?>');
        fbq('track', 'PageView', {}, { eventID: '<?php echo $pv_event_id; ?>' });
    </script>
    <noscript>
        <img height="1" width="1" style="display:none" src="https://www.facebook.com/tr?id=<?php echo htmlspecialchars($active_pixel_id); ?>&ev=PageView&noscript=1" alt="" />
    </noscript>
    <!-- End Meta Pixel Code -->

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Favicon & Touch Icons -->
    <link rel="icon" type="image/x-icon" href="https://res.cloudinary.com/kxvehvqy/image/upload/v1791220684/favicon.ico">
    <link rel="shortcut icon" href="https://res.cloudinary.com/kxvehvqy/image/upload/v1791220684/favicon.ico">
    <link rel="apple-touch-icon" href="https://res.cloudinary.com/kxvehvqy/image/upload/v1791220684/Detox_With_Nova_Logo_250.png">
    <title>Respira Anti-Asthma Herbal Tea | Natural Airway Relief &amp; Wheezing Ease Nigeria</title>
    <meta name="description"
        content="Looking for herbal airway relief or Mullein tea alternative in Nigeria? Respira soothes chest tightness, melts stubborn mucus &amp; calms wheezing. Pay on delivery.">
    <link rel="canonical" href="https://detoxwithnova.xyz/asthma.php">
    
    <!-- Search Engine Crawler Directives -->
    <meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1">
    <meta name="googlebot" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">
    <meta name="bingbot" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">

    <!-- Nigerian Geo-Targeting & Local SEO -->
    <meta name="geo.region" content="NG">
    <meta name="geo.placename" content="Nigeria">
    <meta name="coverage" content="Nigeria">
    <meta name="target" content="all">
    <meta name="rating" content="general">

    <!-- Performance & Preconnect Directives (Core Web Vitals) -->
    <link rel="preconnect" href="https://res.cloudinary.com" crossorigin>
    <link rel="dns-prefetch" href="https://res.cloudinary.com">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <!-- Open Graph (Facebook / WhatsApp / Telegram) -->
    <meta property="og:type" content="product">
    <meta property="og:site_name" content="Detox With Nova">
    <meta property="og:title" content="Respira Anti-Asthma Herbal Tea | Natural Airway Relief &amp; Wheezing Ease">
    <meta property="og:description" content="Natural herbal tea that melts stubborn chest mucus, relieves tight chest, and calms wheezing. 100% organic, NAFDAC certified.">
    <meta property="og:url" content="https://detoxwithnova.xyz/asthma.php">
    <meta property="og:image" content="https://res.cloudinary.com/kxvehvqy/image/upload/v1791221008/RESPIRA_1.jpg">
    <meta property="product:price:amount" content="21500">
    <meta property="product:price:currency" content="NGN">

    <!-- Twitter Summary Card -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="Respira Anti-Asthma Herbal Tea | Natural Airway Relief &amp; Wheezing Ease">
    <meta name="twitter:description" content="Natural herbal tea that melts stubborn chest mucus, relieves tight chest, and calms wheezing. Pay on delivery across Nigeria.">
    <meta name="twitter:image" content="https://res.cloudinary.com/kxvehvqy/image/upload/v1791221008/RESPIRA_1.jpg">

    <!-- Schema.org JSON-LD (Product, Breadcrumbs, Free Delivery & FAQ) for Google Rich Results -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "Product",
          "name": "Respira for Asthma & Airway Relief Herbal Tea",
          "image": "https://res.cloudinary.com/kxvehvqy/image/upload/v1791221008/RESPIRA_1.jpg",
          "description": "Natural herbal tea formula to relieve tight chest, melt stubborn catarrh, and calm whistling wheezing.",
          "sku": "rsp-ast-001",
          "brand": {
            "@type": "Brand",
            "name": "Respira"
          },
          "offers": {
            "@type": "Offer",
            "url": "https://detoxwithnova.xyz/asthma.php",
            "priceCurrency": "NGN",
            "price": "21500",
            "priceValidUntil": "2027-12-31",
            "itemCondition": "https://schema.org/NewCondition",
            "availability": "https://schema.org/InStock",
            "seller": {
              "@type": "Organization",
              "name": "Detox With Nova"
            },
            "shippingDetails": {
              "@type": "OfferShippingDetails",
              "shippingRate": {
                "@type": "MonetaryAmount",
                "value": "0",
                "currency": "NGN"
              },
              "shippingDestination": {
                "@type": "DefinedRegion",
                "addressCountry": "NG"
              },
              "deliveryTime": {
                "@type": "ShippingDeliveryTime",
                "handlingTime": {
                  "@type": "QuantitativeValue",
                  "minValue": 0,
                  "maxValue": 1,
                  "unitCode": "DAY"
                },
                "transitTime": {
                  "@type": "QuantitativeValue",
                  "minValue": 1,
                  "maxValue": 3,
                  "unitCode": "DAY"
                }
              }
            },
            "hasMerchantReturnPolicy": {
              "@type": "MerchantReturnPolicy",
              "applicableCountry": "NG",
              "returnPolicyCategory": "https://schema.org/MerchantReturnFiniteReturnWindow",
              "merchantReturnDays": 7,
              "returnMethod": "https://schema.org/ReturnByMail",
              "returnFees": "https://schema.org/FreeReturn"
            }
          },
          "aggregateRating": {
            "@type": "AggregateRating",
            "ratingValue": "4.9",
            "reviewCount": "120"
          }
        },
        {
          "@type": "BreadcrumbList",
          "itemListElement": [
            {
              "@type": "ListItem",
              "position": 1,
              "name": "Home",
              "item": "https://detoxwithnova.xyz/"
            },
            {
              "@type": "ListItem",
              "position": 2,
              "name": "Lungs & Respiratory Care",
              "item": "https://detoxwithnova.xyz/#products"
            },
            {
              "@type": "ListItem",
              "position": 3,
              "name": "Respira Anti-Asthma Herbal Tea",
              "item": "https://detoxwithnova.xyz/asthma.php"
            }
          ]
        },
        {
          "@type": "Organization",
          "name": "Detox With Nova",
          "legalName": "Detox With Nova (Marketing for Novacare Limited)",
          "url": "https://detoxwithnova.xyz/",
          "logo": "https://res.cloudinary.com/kxvehvqy/image/upload/v1791220685/Detox_With_Nova_Logo_500.png",
          "sameAs": [
            "https://www.facebook.com/detoxwithnova",
            "https://www.instagram.com/emeraldmarketings/?hl=en"
          ],
          "areaServed": "NG"
        },
        {
          "@type": "FAQPage",
          "mainEntity": [
            {
              "@type": "Question",
              "name": "Can herbal tea help relieve asthma wheezing and chest tightness?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Respira Herbal Tea is formulated with natural soothing herbs that melt stubborn chest phlegm, relax tight airways, and calm that whistling chest sound (wheezing) so you can breathe easily and sleep peacefully without gasping for air."
              }
            },
            {
              "@type": "Question",
              "name": "How does Respira compare to Mullein tea for asthma and breathing discomfort?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Both Respira and Mullein tea provide soothing plant benefits that calm irritated lungs. However, loose mullein leaves require meticulous straining to prevent plant hairs from scratching the throat, and imported brands cost ₦29,000+ in Nigeria. Respira comes in smooth, ready-to-steep pyramid teabags, tested and NAFDAC certified, priced at ₦21,500 with free nationwide delivery."
              }
            },
            {
              "@type": "Question",
              "name": "Where can I buy authentic Respira Herbal Tea in Nigeria?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "You can order genuine NAFDAC-approved Respira Herbal Tea directly through this official page. We deliver to all 36 states including Lagos, Abuja, Port Harcourt, Kano, and Ibadan with zero delivery fees and 100% Pay On Delivery."
              }
            },
            {
              "@type": "Question",
              "name": "Can I pay on delivery for Respira in Lagos, Abuja, and other states?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Yes! You can inspect your package when the dispatch rider arrives at your doorstep before paying cash or making an instant bank transfer."
              }
            },
            {
              "@type": "Question",
              "name": "Does Respira replace my asthma inhaler?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "No. Respira is a 100% natural herbal wellness cleanser. It works alongside your prescribed medical treatments to support ongoing airway health and reduce mucus congestion, but does not replace acute inhalers or emergency medical advice."
              }
            },
            {
              "@type": "Question",
              "name": "How often should I drink Respira Herbal Tea?",
              "acceptedAnswer": {
                "@type": "Answer",
                "text": "Drink one cup warm every morning. Steep one teabag in 200ml of boiling water for 5 to 10 minutes to extract the full botanical benefits."
              }
            }
          ]
        }
      ]
    }
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Outfit:wght@600;700;800;900&family=Plus+Jakarta+Sans:wght@500;600;700;800&display=swap"
        rel="stylesheet">
    <style>
        :root {
            --bg-body: #faf9f5;
            --bg-card: #ffffff;
            --primary-green: #047857;
            --primary-green-dark: #064e3b;
            --citrus-yellow: #facc15;
            --text-main: #0f172a;
            --text-sub: #334155;
            --text-muted: #64748b;
            --border-color: #cbd5e1;
            --border-green: #a7f3d0;
            --radius-lg: 16px;
            --shadow-card: 0 8px 20px rgba(15, 23, 42, 0.05);
            --shadow-red: 0 6px 20px rgba(220, 38, 38, 0.35)
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            -webkit-tap-highlight-color: transparent
        }

        html {
            scroll-behavior: smooth;
            font-size: 16px
        }

        body {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--bg-body);
            color: var(--text-main);
            line-height: 1.5;
            overflow-x: hidden
        }

        .container {
            width: 100%;
            max-width: 650px;
            margin: 0 auto;
            padding: 0 14px
        }

        img {
            max-width: 100%;
            height: auto;
            display: block
        }

        h1,
        h2,
        h3,
        h4 {
            font-family: 'Outfit', sans-serif;
            color: var(--text-main);
            line-height: 1.25
        }

        strong {
            font-weight: 800;
            color: var(--text-main)
        }

        .top-bar {
            background: linear-gradient(135deg, #991b1b 0%, #dc2626 50%, #b91c1c 100%);
            color: #fff;
            text-align: center;
            padding: 10px;
            font-size: clamp(0.82rem, 2.5vw, 1rem);
            font-weight: 800;
            position: sticky;
            top: 0;
            z-index: 9999;
            box-shadow: 0 3px 12px rgba(185, 28, 28, 0.35);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid var(--citrus-yellow);
            cursor: pointer
        }

        .timer-box {
            display: inline-block;
            background: #fff;
            color: #b91c1c;
            padding: 1px 7px;
            border-radius: 5px;
            font-weight: 900;
            margin: 0 3px
        }

        .scarcity-pill {
            display: inline-block;
            background: #fef08a;
            color: #854d0e;
            padding: 3px 12px;
            border-radius: 50px;
            font-size: clamp(0.75rem, 2.1vw, 0.85rem);
            font-weight: 900;
            margin-top: 8px;
            border: 1px solid #fde047;
            text-transform: uppercase;
            cursor: pointer
        }

        .section-block {
            padding: 20px 0;
            border-bottom: 1px solid #e2e8f0
        }

        .section-tag {
            display: inline-block;
            background: #ecfdf5;
            color: var(--primary-green-dark);
            border: 1px solid var(--border-green);
            padding: 3px 12px;
            border-radius: 50px;
            font-size: 0.78rem;
            font-weight: 800;
            text-transform: uppercase;
            margin-bottom: 8px;
            letter-spacing: 0.5px;
            cursor: pointer
        }

        .section-title {
            font-size: clamp(1.3rem, 4.2vw, 1.8rem);
            font-weight: 900;
            color: var(--text-main);
            margin-bottom: 8px;
            text-align: center
        }

        .section-title span.green {
            color: var(--primary-green)
        }

        .hero {
            padding: 20px 0 14px;
            text-align: center
        }

        .main-headline {
            font-size: clamp(1.5rem, 4.8vw, 2.2rem);
            font-weight: 900;
            color: var(--text-main);
            margin-bottom: 8px;
            letter-spacing: -0.3px
        }

        .main-headline span.green {
            color: var(--primary-green)
        }

        .sub-headline {
            font-size: clamp(0.95rem, 2.7vw, 1.15rem);
            color: var(--text-sub);
            margin-bottom: 12px;
            font-weight: 600;
            line-height: 1.45
        }

        .product-showcase-box {
            background: var(--bg-card);
            border: 2px solid var(--border-green);
            border-radius: var(--radius-lg);
            padding: 16px;
            margin: 14px 0;
            box-shadow: var(--shadow-card);
            text-align: center;
            cursor: pointer
        }

        .img-placeholder-box {
            background: #f8fafc;
            border: 2px dashed #94a3b8;
            border-radius: 12px;
            padding: 20px 14px;
            margin: 12px 0;
            text-align: center
        }

        .img-placeholder-box .img-desc {
            font-size: clamp(0.82rem, 2.3vw, 0.92rem);
            color: #475569;
            font-weight: 600;
            line-height: 1.5;
            font-style: italic
        }

        .img-placeholder-box .img-label {
            display: inline-block;
            margin-top: 8px;
            background: #e2e8f0;
            color: #64748b;
            font-size: 0.72rem;
            font-weight: 800;
            padding: 2px 10px;
            border-radius: 50px;
            text-transform: uppercase;
            letter-spacing: 0.5px
        }

        .problem-card-grid {
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-top: 14px
        }

        .problem-item {
            background: #fef2f2;
            border: 1.5px solid #fecaca;
            border-radius: 12px;
            padding: 14px
        }

        .problem-header-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 8px
        }

        .problem-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 32px;
            height: 32px;
            background: #fee2e2;
            color: #dc2626;
            font-size: 0.85rem;
            font-weight: 900;
            border-radius: 8px;
            flex-shrink: 0
        }

        .problem-text h4 {
            font-size: clamp(1.15rem, 3.5vw, 1.38rem);
            color: #991b1b;
            font-weight: 900;
            margin-bottom: 4px
        }

        .problem-text p {
            font-size: clamp(0.95rem, 2.8vw, 1.1rem);
            color: #7f1d1d;
            line-height: 1.45;
            font-weight: 600
        }

        .solution-card {
            background: #ecfdf5;
            border: 2px solid var(--primary-green);
            border-radius: var(--radius-lg);
            padding: 16px 14px;
            margin-top: 14px;
            text-align: center;
            cursor: pointer
        }

        .solution-card h3 {
            font-size: clamp(1.1rem, 3.3vw, 1.4rem);
            color: var(--primary-green-dark);
            font-weight: 900;
            margin-bottom: 6px
        }

        .solution-card p {
            font-size: clamp(0.88rem, 2.5vw, 1rem);
            color: var(--text-sub);
            line-height: 1.45;
            font-weight: 600;
            margin-bottom: 12px
        }

        .solution-badge-row {
            display: flex;
            justify-content: center;
            gap: 6px;
            flex-wrap: wrap
        }

        .sol-badge {
            background: #fff;
            border: 1px solid var(--border-green);
            color: var(--primary-green-dark);
            padding: 3px 10px;
            border-radius: 50px;
            font-size: 0.78rem;
            font-weight: 800
        }

        .how-to-steps {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 14px
        }

        .step-row {
            display: flex;
            align-items: center;
            gap: 12px;
            background: var(--bg-card);
            border: 1.5px solid var(--border-green);
            border-radius: 10px;
            padding: 12px
        }

        .step-num {
            background: var(--primary-green);
            color: #fff;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Outfit', sans-serif;
            font-size: 1rem;
            font-weight: 900;
            flex-shrink: 0
        }

        .step-text {
            font-size: clamp(0.9rem, 2.5vw, 1rem);
            color: var(--text-sub);
            font-weight: 700
        }

        .pricing-card {
            background: var(--bg-card);
            border: 2px solid var(--primary-green);
            border-radius: var(--radius-lg);
            padding: 18px 14px;
            margin-top: 16px;
            box-shadow: var(--shadow-card)
        }

        .package-grid {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 12px
        }

        .package-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: var(--bg-body);
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            padding: 10px 12px;
            cursor: pointer;
            position: relative
        }

        .package-item.popular {
            background: #ecfdf5;
            border-color: var(--primary-green);
            box-shadow: 0 3px 12px rgba(4, 120, 87, 0.12)
        }

        .popular-badge {
            position: absolute;
            top: -9px;
            right: 12px;
            background: #dc2626;
            color: #fff;
            font-size: 0.65rem;
            font-weight: 900;
            padding: 2px 8px;
            border-radius: 50px;
            text-transform: uppercase
        }

        .package-info h4 {
            font-size: clamp(0.9rem, 2.6vw, 1.05rem);
            color: var(--text-main);
            font-weight: 800
        }

        .package-info p {
            font-size: clamp(0.75rem, 2.1vw, 0.85rem);
            color: var(--text-sub);
            font-weight: 600
        }

        .package-price {
            text-align: right;
            font-family: 'Outfit', sans-serif;
            font-size: clamp(1.05rem, 3.2vw, 1.3rem);
            color: var(--primary-green-dark);
            font-weight: 900
        }

        .carousel-wrapper {
            position: relative;
            overflow: hidden;
            border-radius: 14px;
            border: 2px solid var(--border-green);
            background: #0e2417;
            padding: 14px 10px 38px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.12);
            margin-top: 14px;
            margin-bottom: 16px
        }

        .carousel-track-container {
            overflow: hidden;
            width: 100%;
            border-radius: 10px
        }

        .carousel-track {
            display: flex;
            transition: transform 0.35s cubic-bezier(0.25, 1, 0.5, 1);
            will-change: transform
        }

        .carousel-slide {
            min-width: 100%;
            box-sizing: border-box;
            padding: 0 4px;
            text-align: center
        }

        .carousel-slide img {
            border-radius: 10px;
            border: 1.5px solid var(--border-green);
            width: 100%;
            max-height: 380px;
            object-fit: contain;
            cursor: zoom-in
        }

        .carousel-caption {
            font-size: clamp(0.92rem, 2.7vw, 1.1rem);
            color: #4ade80;
            font-weight: 800;
            margin-top: 10px;
            padding: 0 6px;
            line-height: 1.35
        }

        .zoom-hint {
            font-size: clamp(0.78rem, 2.2vw, 0.88rem);
            color: #86efac;
            margin-top: 3px;
            font-weight: 700
        }

        .carousel-nav-btn {
            position: absolute;
            top: 45%;
            transform: translateY(-50%);
            background: rgba(220, 38, 38, 0.92);
            color: #fff;
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            font-size: 1.2rem;
            font-weight: 900;
            cursor: pointer;
            z-index: 10;
            display: flex;
            align-items: center;
            justify-content: center
        }

        .carousel-nav-btn.prev-btn {
            left: 8px
        }

        .carousel-nav-btn.next-btn {
            right: 8px
        }

        .carousel-dots {
            display: flex;
            justify-content: center;
            gap: 6px;
            position: absolute;
            bottom: 12px;
            left: 50%;
            transform: translateX(-50%)
        }

        .carousel-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.35);
            cursor: pointer
        }

        .carousel-dot.active {
            background: #dc2626;
            width: 20px;
            border-radius: 8px
        }

        .lightbox-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(4, 12, 7, 0.95);
            z-index: 999999;
            align-items: center;
            justify-content: center;
            padding: 14px;
            backdrop-filter: blur(6px)
        }

        .lightbox-modal.active {
            display: flex
        }

        .lightbox-content {
            position: relative;
            max-width: 95%;
            max-height: 92vh;
            text-align: center
        }

        .lightbox-content img {
            max-width: 100%;
            max-height: 88vh;
            border-radius: 10px;
            border: 2px solid var(--border-green);
            object-fit: contain;
            margin: 0 auto
        }

        .close-lightbox {
            position: absolute;
            top: -16px;
            right: -12px;
            background: #dc2626;
            color: #fff;
            width: 34px;
            height: 34px;
            border-radius: 50%;
            font-size: 1.3rem;
            font-weight: 900;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            border: 2px solid #fff
        }

        .trust-cards-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
            margin-top: 14px;
            text-align: center
        }

        .trust-card {
            background: var(--bg-card);
            border: 1.5px solid var(--border-color);
            border-radius: 10px;
            padding: 8px 4px;
            cursor: pointer
        }

        .trust-card span.icon {
            font-size: 1.3rem;
            display: block;
            margin-bottom: 2px
        }

        .trust-card h4 {
            font-size: clamp(0.78rem, 2.1vw, 0.9rem);
            color: var(--primary-green);
            font-weight: 800
        }

        .trust-card p {
            font-size: clamp(0.68rem, 1.8vw, 0.78rem);
            color: var(--text-muted);
            line-height: 1.2;
            font-weight: 600
        }

        .btn-cta {
            display: block;
            width: 100%;
            max-width: 480px;
            margin: 0 auto;
            background: linear-gradient(180deg, #ef4444 0%, #dc2626 50%, #b91c1c 100%);
            color: #fff !important;
            text-align: center;
            font-family: 'Outfit', sans-serif;
            font-size: clamp(1rem, 3.2vw, 1.25rem);
            font-weight: 900;
            padding: 13px 18px;
            border-radius: 50px;
            text-decoration: none;
            text-transform: uppercase;
            box-shadow: var(--shadow-red);
            border: 2px solid #fca5a5;
            cursor: pointer;
            transition: transform 0.2s ease, background 0.2s ease;
            letter-spacing: 0.5px;
            position: relative;
            overflow: hidden;
            animation: ctaPulse 2.5s infinite ease-in-out;
            white-space: nowrap;
            max-width: 380px;
        }

        .btn-cta-sm {
            padding: 9px 14px;
            font-size: clamp(0.82rem, 2.3vw, 0.95rem);
            max-width: 280px;
            border-radius: 30px;
            margin-top: 8px;
            white-space: nowrap;
            max-width: 200px;
        }

        .btn-cta-md {
            padding: 11px 16px;
            font-size: clamp(0.92rem, 2.6vw, 1.08rem);
            max-width: 360px;
            border-radius: 40px;
            margin-top: 10px;
            white-space: nowrap;
            max-width: 280px;
        }

        .btn-cta::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -60%;
            width: 40%;
            height: 200%;
            background: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.45) 50%, rgba(255, 255, 255, 0) 100%);
            transform: rotate(25deg);
            animation: shimmerSweep 3.5s infinite ease-in-out;
            pointer-events: none
        }

        .btn-cta:hover {
            background: linear-gradient(180deg, #f87171 0%, #ef4444 100%);
            transform: translateY(-2px)
        }

        .btn-cta:active {
            transform: scale(0.98)
        }

        .cta-subtext {
            text-align: center;
            font-size: clamp(0.8rem, 2.2vw, 0.9rem);
            color: var(--text-muted);
            margin-top: 6px;
            font-weight: 700
        }

        @keyframes ctaPulse {

            0%,
            100% {
                box-shadow: 0 6px 20px rgba(220, 38, 38, 0.35), 0 0 0 0 rgba(220, 38, 38, 0.25)
            }

            50% {
                box-shadow: 0 10px 28px rgba(220, 38, 38, 0.55), 0 0 0 8px rgba(220, 38, 38, 0)
            }
        }

        @keyframes shimmerSweep {
            0% {
                left: -60%
            }

            30% {
                left: 140%
            }

            100% {
                left: 140%
            }
        }

        .transition-box {
            background: #fffbeb;
            border: 1.5px solid #fde68a;
            border-radius: var(--radius-lg);
            padding: 14px 12px;
            margin: 14px 0;
            text-align: center
        }

        .transition-box p {
            font-size: clamp(0.92rem, 2.7vw, 1.05rem);
            color: #92400e;
            font-weight: 700;
            line-height: 1.5
        }

        .safety-note {
            background: #f0fdf4;
            border: 1px solid var(--border-green);
            border-radius: 10px;
            padding: 10px 12px;
            margin-top: 14px;
            font-size: clamp(0.78rem, 2.1vw, 0.85rem);
            color: #166534;
            font-weight: 600;
            text-align: center;
            line-height: 1.4
        }

        .warning-box {
            background: #fef2f2;
            border: 2px dashed #ef4444;
            border-radius: var(--radius-lg);
            padding: 14px 12px;
            margin-bottom: 14px;
            text-align: center
        }

        .warning-box h3 {
            color: #b91c1c;
            font-size: clamp(0.98rem, 2.8vw, 1.15rem);
            font-weight: 900;
            margin-bottom: 4px;
            text-transform: uppercase
        }

        .warning-box p {
            font-size: clamp(0.82rem, 2.3vw, 0.92rem);
            color: #991b1b;
            line-height: 1.4;
            font-weight: 700
        }

        .crm-container-box {
            background: var(--bg-card);
            border-radius: var(--radius-lg);
            padding: 18px 14px;
            border: 2px solid var(--primary-green);
            box-shadow: var(--shadow-card);
            text-align: center
        }

        .crm-container-box h3 {
            font-size: clamp(1.15rem, 3.3vw, 1.45rem);
            color: var(--primary-green-dark);
            font-weight: 900;
            margin-bottom: 4px
        }

        .crm-container-box p {
            font-size: clamp(0.85rem, 2.4vw, 0.95rem);
            color: var(--text-sub);
            margin-bottom: 12px;
            font-weight: 600
        }

        .crm-iframe-wrapper {
            width: 100%;
            max-width: 720px;
            margin: 0 auto;
            border-radius: 10px;
            overflow: hidden;
            background: #fff;
            border: 1px solid var(--border-color);
            position: relative
        }

        .crm-iframe-wrapper iframe {
            width: 100%;
            max-width: 720px;
            border: 0;
            min-height: 700px;
            height: 730px;
            display: block
        }

        .iframe-fallback-notice {
            display: none;
            background: #fef2f2;
            border: 1.5px solid #dc2626;
            padding: 12px;
            border-radius: 8px;
            color: #991b1b;
            margin-top: 10px;
            font-size: 0.88rem
        }


        footer {
            background: #022c22;
            color: #a7f3d0;
            text-align: center;
            padding: 24px 14px 28px;
            font-size: clamp(0.78rem, 2.2vw, 0.88rem);
            margin-top: 30px;
            border-top: 3px solid var(--citrus-yellow)
        }

        footer h4 {
            color: #fff;
            font-size: clamp(0.95rem, 2.7vw, 1.1rem);
            margin-bottom: 4px;
            font-weight: 800
        }

        footer p {
            line-height: 1.45;
            margin-bottom: 4px
        }

        .footer-links a {
            color: #fff;
            text-decoration: underline;
            margin: 0 6px
        }

        @media(max-width:480px) {
            .trust-cards-row {
                grid-template-columns: 1fr;
                gap: 6px
            }
        }

        /* ============================================================
   RESPONSIVE LAYOUT SYSTEM (MOBILE, TABLET & DESKTOP)
   ============================================================ */
        .hero-grid {
            display: block;
        }

        .hero-cta-desktop {
            display: none;
        }

        .hero-cta-mobile {
            display: block;
            margin-top: 14px;
        }

        .solution-grid {
            display: block;
        }

        /* --- TABLET SCREEN (min-width: 768px) --- */
        @media (min-width: 768px) {
            .container {
                max-width: 720px !important;
                padding: 0 24px !important;
            }

            .section-block {
                padding: 28px 0;
            }

            .section-title {
                font-size: 1.85rem;
                margin-bottom: 14px;
            }

            /* 2-Column Hero */
            .hero {
                padding: 24px 0 16px;
                text-align: left;
            }

            .hero-grid {
                display: block !important;
                width: 100% !important;
            }

            .hero-text-col {
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                text-align: left;
            }

            .hero-text-col div {
                text-align: left !important;
            }

            .hero-text-col .main-headline {
                text-align: left;
                font-size: clamp(1.8rem, 3.2vw, 2.3rem);
                line-height: 1.22;
                margin-bottom: 10px;
            }

            .hero-text-col .sub-headline {
                text-align: left;
                font-size: 1.05rem;
                line-height: 1.45;
                margin-bottom: 12px;
            }

            .hero-text-col .scarcity-pill {
                margin: 4px 0 16px 0;
            }

            .hero-cta-desktop {
                display: block;
                width: 100%;
                margin-top: 8px;
            }

            .hero-cta-desktop .btn-cta {
                margin: 0;
                max-width: 320px;
            }

            .hero-cta-desktop .cta-subtext {
                text-align: left;
                margin-top: 6px;
            }

            .hero-cta-mobile {
                display: none;
            }

            .hero-media-col .product-showcase-box {
                margin: 0;
                padding: 18px;
            }

            /* 2x2 Problem Cards */
            .problem-card-grid {
                display: flex !important;
                flex-direction: column !important;
                width: 100% !important;
            }

            .problem-item {
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 18px 16px;
                margin: 0;
            }

            .problem-item img {
                margin: 12px 0 auto;
            }

            .problem-item .btn-cta-sm {
                margin-top: 12px;
                align-self: flex-start;
            }

            /* 2-Column Solution Section */
            .solution-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 24px;
                align-items: stretch;
                margin-top: 18px;
            }

            .solution-card {
                margin-top: 0;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
                text-align: left;
                padding: 24px 20px;
                box-sizing: border-box;
            }

            .solution-badge-row {
                justify-content: flex-start;
            }

            .solution-media-col {
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            /* 4-Column Step Pipeline */
            .how-to-steps {
                display: grid !important;
                grid-template-columns: repeat(4, 1fr) !important;
                gap: 12px !important;
                margin-top: 18px !important;
            }

            .step-row {
                flex-direction: column !important;
                text-align: center !important;
                padding: 18px 10px !important;
                justify-content: flex-start !important;
                height: 100% !important;
                box-sizing: border-box !important;
            }

            .step-num {
                margin-bottom: 8px;
                width: 36px;
                height: 36px;
                font-size: 1rem;
            }

            .step-text {
                font-size: 0.9rem;
            }

            /* 4-Column Pricing Table */
            .package-grid {
                display: grid !important;
                grid-template-columns: repeat(4, 1fr) !important;
                gap: 10px !important;
                margin-top: 16px !important;
                align-items: stretch !important;
            }

            .package-item {
                flex-direction: column !important;
                justify-content: space-between !important;
                align-items: center !important;
                text-align: center !important;
                padding: 18px 10px !important;
                box-sizing: border-box !important;
            }

            .package-price {
                margin-top: 10px;
                font-size: 1.3rem;
            }

            .package-item.popular {
                transform: scale(1.03);
                z-index: 2;
            }

            .pricing-card {
                padding: 24px 20px;
            }

            /* Carousel and Trust Rows */
            .carousel-wrapper {
                max-width: 740px;
                margin: 0 auto;
            }

            .carousel-slide img {
                max-width: 440px;
                margin: 0 auto;
            }

            .carousel-caption {
                max-width: 540px;
                margin: 10px auto 0;
            }

            .trust-cards-row {
                gap: 16px;
                max-width: 820px;
                margin: 20px auto 0;
            }

            .trust-card {
                padding: 16px 12px;
            }

            /* Transitions & Form */
            .transition-box {
                max-width: 820px;
                margin: 20px auto;
                padding: 18px 24px;
            }

            .warning-box {
                max-width: 740px;
                margin: 0 auto 16px;
            }

            .crm-container-box {
                max-width: 740px;
                margin: 0 auto;
                padding: 24px 20px;
            }
        }

        /* --- DESKTOP SCREEN (min-width: 1024px) --- */
        @media (min-width: 1024px) {
            .container {
                max-width: 720px !important;
                padding: 0 32px !important;
            }

            .section-block {
                padding: 36px 0;
            }

            .section-title {
                font-size: 2.15rem;
                margin-bottom: 16px;
            }

            .hero {
                padding: 36px 0 24px;
            }

            .hero-grid {
                display: block !important;
                width: 100% !important;
            }

            .hero-text-col .main-headline {
                font-size: 2.6rem;
                line-height: 1.2;
            }

            .hero-text-col .sub-headline {
                font-size: 1.15rem;
                line-height: 1.5;
            }

            .hero-cta-desktop .btn-cta {
                max-width: 340px;
                padding: 14px 24px;
                font-size: 1.1rem;
            }

            .hero-media-col .product-showcase-box {
                padding: 22px;
            }

            .problem-card-grid {
                gap: 24px !important;
                margin-top: 24px !important;
            }

            .problem-item {
                padding: 24px 22px;
                border-radius: 14px;
            }

            .problem-text h4 {
                font-size: 1.35rem;
            }

            .problem-text p {
                font-size: 1.05rem;
            }

            .solution-grid {
                gap: 36px;
                margin-top: 24px;
            }

            .solution-card {
                padding: 32px 28px;
            }

            .solution-card h3 {
                font-size: 1.45rem;
            }

            .solution-card p {
                font-size: 1.05rem;
            }

            .how-to-steps {
                gap: 16px !important;
                margin-top: 24px !important;
            }

            .step-row {
                padding: 24px 14px !important;
                border-radius: 12px;
            }

            .step-num {
                width: 42px;
                height: 42px;
                font-size: 1.15rem;
                margin-bottom: 12px;
            }

            .step-text {
                font-size: 0.98rem;
            }

            .package-grid {
                gap: 16px !important;
                margin-top: 20px !important;
            }

            .package-item {
                padding: 24px 14px !important;
                border-radius: 12px;
            }

            .package-info h4 {
                font-size: 0.95rem;
            }

            .package-price {
                font-size: 1.45rem;
                margin-top: 14px;
            }

            .package-item.popular {
                transform: scale(1.05);
            }

            .pricing-card {
                padding: 32px 24px;
                margin-top: 24px;
            }

            .carousel-wrapper {
                max-width: 840px;
            }

            .carousel-slide img {
                max-width: 480px;
            }

            .trust-cards-row {
                gap: 24px;
                max-width: 880px;
                margin: 28px auto 0;
            }

            .trust-card {
                padding: 20px 16px;
            }

            .crm-container-box {
                max-width: 780px;
                padding: 32px 24px;
            }
        }

        /* ============================================================
   PREMIUM HERO DESIGN (MOBILE, TABLET & DESKTOP)
   ============================================================ */
        .hero {
            padding: 16px 0 14px;
            text-align: center;
        }

        .hero-grid {
            display: block;
        }

        .hero-pill-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            background: #ecfdf5;
            color: var(--primary-green-dark);
            border: 1px solid var(--border-green);
            padding: 4px 14px;
            border-radius: 50px;
            font-size: 0.76rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
            cursor: pointer;
        }

        .badge-live-dot {
            width: 7px;
            height: 7px;
            background: #10b981;
            border-radius: 50%;
            display: inline-block;
            box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.3);
        }

        .hero-checklist {
            display: flex;
            flex-direction: column;
            gap: 7px;
            margin: 12px 0 14px;
            text-align: left;
        }

        .hero-check-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: clamp(0.85rem, 2.2vw, 0.95rem);
            color: var(--text-main);
            font-weight: 700;
        }

        .check-svg {
            width: 18px;
            height: 18px;
            color: var(--primary-green);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .check-svg svg {
            width: 100%;
            height: 100%;
        }

        .hero-scarcity-row {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            background: #fef9c3;
            color: #854d0e;
            border: 1px solid #fde047;
            padding: 5px 14px;
            border-radius: 50px;
            font-size: clamp(0.72rem, 2vw, 0.8rem);
            font-weight: 800;
            letter-spacing: 0.4px;
            margin: 6px 0 14px;
            cursor: pointer;
        }

        .scarcity-dot {
            width: 6px;
            height: 6px;
            background: #dc2626;
            border-radius: 50%;
            display: inline-block;
            animation: pulseRed 1.8s infinite;
        }

        @keyframes pulseRed {

            0%,
            100% {
                opacity: 1;
                transform: scale(1);
            }

            50% {
                opacity: 0.4;
                transform: scale(0.8);
            }
        }

        /* Modern Framed Hero Image Card */
        .hero-image-card {
            position: relative;
            border-radius: 16px;
            overflow: hidden;
            background: #fff;
            box-shadow: 0 18px 38px -10px rgba(4, 78, 56, 0.18), 0 0 0 1px rgba(4, 120, 87, 0.15);
            margin: 12px 0;
            cursor: pointer;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .hero-image-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 24px 46px -10px rgba(4, 78, 56, 0.24), 0 0 0 1px rgba(4, 120, 87, 0.22);
        }

        .hero-image-card img,
        .hero-image-card video {
            width: 100% !important;
            height: auto !important;
            display: block !important;
            border: none !important;
            margin: 0 !important;
            border-radius: 0 !important;
            object-fit: cover;
        }

        .hero-image-overlay-badge {
            position: absolute;
            bottom: 12px;
            left: 12px;
            background: rgba(2, 44, 34, 0.9);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            color: #a7f3d0;
            font-size: 0.72rem;
            font-weight: 800;
            padding: 5px 12px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            letter-spacing: 0.3px;
            border: 1px solid rgba(167, 243, 208, 0.25);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .badge-icon {
            display: inline-flex;
            align-items: center;
            color: #34d399;
        }

        .hero-cta-desktop {
            display: none;
        }

        .hero-cta-mobile {
            display: block;
            margin-top: 14px;
        }

        /* TABLET */
        @media (min-width: 768px) {
            .hero {
                padding: 30px 24px 24px;
                text-align: left;
                background: radial-gradient(circle at 90% 20%, rgba(167, 243, 208, 0.25) 0%, transparent 65%);
                border-radius: 18px;
                margin: 12px 0 20px;
            }

            .hero-grid {
                display: block !important;
                width: 100% !important;
            }

            .hero-text-col {
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                text-align: left;
            }

            .hero-text-col div {
                text-align: left !important;
            }

            .hero-text-col .main-headline {
                text-align: left;
                font-size: clamp(1.85rem, 3.2vw, 2.35rem);
                line-height: 1.2;
                margin-bottom: 10px;
            }

            .hero-text-col .sub-headline {
                text-align: left;
                font-size: 1.05rem;
                line-height: 1.5;
                margin-bottom: 8px;
            }

            .hero-image-card {
                margin: 0;
            }

            .hero-cta-desktop {
                display: block;
                width: 100%;
                margin-top: 10px;
            }

            .hero-cta-desktop .btn-cta {
                margin: 0;
                max-width: 320px;
                box-shadow: 0 10px 24px -4px rgba(220, 38, 38, 0.4);
            }

            .hero-cta-desktop .cta-subtext {
                text-align: left;
                margin-top: 6px;
            }

            .hero-cta-mobile {
                display: none;
            }
        }

        /* DESKTOP */
        @media (min-width: 1024px) {
            .hero {
                padding: 40px 36px 32px;
                background: radial-gradient(circle at 90% 20%, rgba(167, 243, 208, 0.3) 0%, transparent 65%);
                border-radius: 20px;
                margin: 16px 0 28px;
                border: 1px solid rgba(167, 243, 208, 0.4);
            }

            .hero-grid {
                display: block !important;
                width: 100% !important;
            }

            .hero-text-col .main-headline {
                font-size: 2.55rem;
                line-height: 1.18;
            }

            .hero-text-col .sub-headline {
                font-size: 1.12rem;
                line-height: 1.55;
            }

            .hero-checklist {
                gap: 9px;
                margin: 14px 0 16px;
            }

            .hero-check-item {
                font-size: 0.98rem;
            }

            .hero-scarcity-row {
                margin: 4px 0 16px;
            }

            .hero-cta-desktop .btn-cta {
                max-width: 340px;
                padding: 14px 24px;
                font-size: 1.1rem;
            }

            .hero-image-card {
                border-radius: 18px;
            }

            .hero-image-overlay-badge {
                font-size: 0.78rem;
                padding: 6px 14px;
                bottom: 14px;
                left: 14px;
            }
        }

        /* Hide duplicate desktop CTA inside text column so single CTA sits under hero media */
        .hero-cta-desktop {
            display: none !important;
        }

        .hero-media-col {
            display: block !important;
            width: 100% !important;
            margin: 14px auto 0 !important;
        }

        .hero-image-card,
        .hero-media-col .product-showcase-box {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 auto !important;
            display: block !important;
            box-sizing: border-box !important;
        }

        .hero-image-card img,
        .hero-media-col .product-showcase-box img {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            border-radius: 14px !important;
        }

        .hero-cta-mobile {
            display: block !important;
            width: 100% !important;
            margin-top: 14px !important;
        }

        .hero-cta-mobile .btn-cta {
            width: 100% !important;
            max-width: 480px !important;
            margin: 0 auto !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
        }

        .hero-cta-mobile .cta-subtext {
            text-align: center !important;
            margin-top: 6px !important;
        }

        /* Problem Section: Normal stacked, covering full width */
        .problem-card-grid {
            display: flex !important;
            flex-direction: column !important;
            gap: 18px !important;
            margin-top: 18px !important;
            width: 100% !important;
        }

        .problem-item {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            box-sizing: border-box !important;
            padding: 20px 18px !important;
            border-radius: 14px !important;
            margin: 0 !important;
        }

        .problem-header-row {
            display: flex !important;
            align-items: flex-start !important;
            gap: 12px !important;
            margin-bottom: 10px !important;
        }

        .problem-text {
            flex: 1 !important;
        }

        .problem-text h4 {
            font-size: clamp(1.15rem, 3.2vw, 1.38rem) !important;
            line-height: 1.3 !important;
            margin-bottom: 4px !important;
        }

        .problem-text p {
            font-size: clamp(0.92rem, 2.5vw, 1.05rem) !important;
            line-height: 1.5 !important;
        }

        .problem-item img,
        .problem-item video,
        .problem-item .media-placeholder-card {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            margin: 12px 0 !important;
            border-radius: 12px !important;
        }

        .problem-item .btn-cta,
        .problem-item .btn-cta-sm {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            width: 100% !important;
            max-width: 420px !important;
            margin: 12px auto 0 !important;
            text-align: center !important;
        }

        .transition-box {
            width: 100% !important;
            box-sizing: border-box !important;
            margin: 18px auto 0 !important;
        }

        /* ============================================================
   RESPONSIVE DESKTOP EXPANSION: FULL-WIDTH STACKED & SCALED TYPOGRAPHY
   ============================================================ */
        html {
            font-size: 16px;
        }

        .container {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 auto !important;
            padding: 0 16px !important;
            box-sizing: border-box !important;
        }

        .hero {
            padding: 20px 0 16px !important;
            text-align: center !important;
            width: 100% !important;
            display: block !important;
            background: transparent !important;
            margin: 0 !important;
            border: none !important;
        }

        .hero-grid {
            display: block !important;
            width: 100% !important;
            margin: 0 auto !important;
        }

        .hero-text-col {
            display: block !important;
            width: 100% !important;
            text-align: center !important;
            margin: 0 auto !important;
        }

        .hero-text-col div {
            text-align: center !important;
        }

        .hero-text-col .main-headline {
            text-align: center !important;
            font-size: clamp(1.65rem, 4.2vw, 2.45rem) !important;
            line-height: 1.22 !important;
            margin: 0 auto 12px !important;
            width: 100% !important;
            max-width: 100% !important;
        }

        .hero-text-col .sub-headline {
            text-align: center !important;
            font-size: clamp(0.95rem, 2.4vw, 1.18rem) !important;
            line-height: 1.55 !important;
            margin: 0 auto 14px !important;
            width: 100% !important;
            max-width: 820px !important;
            color: var(--text-sub) !important;
        }

        .hero-checklist {
            display: flex !important;
            flex-direction: column !important;
            align-items: flex-start !important;
            max-width: 520px !important;
            margin: 12px auto 14px !important;
            text-align: left !important;
            width: 100% !important;
        }

        .hero-scarcity-row,
        .scarcity-pill {
            margin: 8px auto 14px !important;
            display: inline-flex !important;
            text-align: center !important;
        }

        .hero-cta-desktop {
            display: none !important;
        }

        .hero-media-col {
            display: block !important;
            width: 100% !important;
            margin: 16px auto 0 !important;
        }

        .hero-image-card,
        .hero-media-col .product-showcase-box {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 auto !important;
            display: block !important;
            box-sizing: border-box !important;
        }

        .hero-image-card img,
        .hero-media-col .product-showcase-box img {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            border-radius: 14px !important;
        }

        .hero-cta-mobile {
            display: block !important;
            width: 100% !important;
            margin-top: 16px !important;
        }

        .hero-cta-mobile .btn-cta {
            width: 100% !important;
            max-width: 520px !important;
            margin: 0 auto !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
        }

        .hero-cta-mobile .cta-subtext {
            text-align: center !important;
            margin-top: 6px !important;
        }

        /* Problem Section: Normal stacked, covering full width */
        .problem-card-grid {
            display: flex !important;
            flex-direction: column !important;
            gap: 18px !important;
            margin-top: 18px !important;
            width: 100% !important;
        }

        .problem-item {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            box-sizing: border-box !important;
            padding: 22px 18px !important;
            border-radius: 14px !important;
            margin: 0 !important;
        }

        .problem-header-row {
            display: flex !important;
            align-items: flex-start !important;
            gap: 12px !important;
            margin-bottom: 10px !important;
        }

        .problem-text {
            flex: 1 !important;
        }

        .problem-text h4 {
            font-size: clamp(1.15rem, 3vw, 1.45rem) !important;
            line-height: 1.3 !important;
            margin-bottom: 5px !important;
        }

        .problem-text p {
            font-size: clamp(0.95rem, 2.2vw, 1.12rem) !important;
            line-height: 1.55 !important;
        }

        .problem-item img,
        .problem-item video,
        .problem-item .media-placeholder-card {
            width: 100% !important;
            max-width: 100% !important;
            display: block !important;
            margin: 14px 0 !important;
            border-radius: 12px !important;
        }

        .problem-item .btn-cta,
        .problem-item .btn-cta-sm {
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            width: 100% !important;
            max-width: 480px !important;
            margin: 14px auto 0 !important;
            text-align: center !important;
        }

        .transition-box {
            width: 100% !important;
            box-sizing: border-box !important;
            margin: 20px auto 0 !important;
        }

        /* --- TABLET SCREEN (min-width: 768px): WIDTH & TEXT INCREASE --- */
        @media (min-width: 768px) {
            html {
                font-size: 17px;
            }

            .container {
                max-width: 860px !important;
                padding: 0 28px !important;
            }

            .hero {
                padding: 28px 0 20px !important;
            }

            .hero-text-col .main-headline {
                font-size: 2.35rem !important;
                line-height: 1.22 !important;
                margin-bottom: 14px !important;
            }

            .hero-text-col .sub-headline {
                font-size: 1.15rem !important;
                line-height: 1.6 !important;
                margin-bottom: 16px !important;
            }

            .hero-checklist {
                max-width: 580px !important;
                gap: 10px !important;
            }

            .hero-check-item {
                font-size: 1.05rem !important;
            }

            .hero-cta-mobile .btn-cta {
                font-size: 1.18rem !important;
                padding: 16px 32px !important;
                max-width: 520px !important;
            }

            .section-title {
                font-size: 2.15rem !important;
                margin-bottom: 16px !important;
            }

            .section-tag {
                font-size: 0.88rem !important;
                padding: 5px 16px !important;
            }

            .problem-card-grid {
                gap: 22px !important;
                margin-top: 22px !important;
            }

            .problem-item {
                padding: 26px 26px !important;
                border-radius: 16px !important;
            }

            .problem-number {
                min-width: 38px !important;
                height: 38px !important;
                font-size: 0.98rem !important;
            }

            .problem-text h4 {
                font-size: 1.45rem !important;
            }

            .problem-text p {
                font-size: 1.12rem !important;
            }

            .problem-item .btn-cta,
            .problem-item .btn-cta-sm {
                font-size: 1.08rem !important;
                padding: 14px 28px !important;
                max-width: 480px !important;
            }

            .transition-box {
                padding: 22px 24px !important;
                font-size: 1.15rem !important;
            }

            .solution-card {
                padding: 26px 24px !important;
            }

            .solution-card h3 {
                font-size: 1.55rem !important;
            }

            .solution-card p {
                font-size: 1.1rem !important;
            }

            .crm-container-box {
                padding: 30px 28px !important;
            }
        }

        /* --- DESKTOP SCREEN (min-width: 1024px): EXPANDED FULL-WIDTH & SCALED TYPOGRAPHY --- */
        @media (min-width: 1024px) {
            html {
                font-size: 18px;
            }

            .container {
                max-width: 1060px !important;
                padding: 0 36px !important;
            }

            .hero {
                padding: 36px 0 24px !important;
            }

            .hero-pill-badge {
                font-size: 0.88rem !important;
                padding: 6px 18px !important;
            }

            .hero-text-col .main-headline {
                font-size: 2.85rem !important;
                line-height: 1.2 !important;
                margin-bottom: 16px !important;
                max-width: 960px !important;
            }

            .hero-text-col .sub-headline {
                font-size: 1.3rem !important;
                line-height: 1.62 !important;
                margin-bottom: 18px !important;
                max-width: 860px !important;
            }

            .hero-checklist {
                max-width: 640px !important;
                gap: 12px !important;
                margin: 16px auto 18px !important;
            }

            .hero-check-item {
                font-size: 1.15rem !important;
                gap: 12px !important;
            }

            .check-svg {
                width: 22px !important;
                height: 22px !important;
            }

            .hero-scarcity-row,
            .scarcity-pill {
                font-size: 0.95rem !important;
                padding: 7px 20px !important;
                margin: 10px auto 18px !important;
            }

            .hero-image-card,
            .hero-media-col .product-showcase-box {
                border-radius: 20px !important;
            }

            .hero-image-card img,
            .hero-media-col .product-showcase-box img {
                border-radius: 18px !important;
            }

            .hero-image-overlay-badge {
                font-size: 0.92rem !important;
                padding: 8px 18px !important;
                bottom: 18px !important;
                left: 18px !important;
            }

            .hero-cta-mobile {
                margin-top: 20px !important;
            }

            .hero-cta-mobile .btn-cta {
                font-size: 1.3rem !important;
                padding: 18px 40px !important;
                max-width: 580px !important;
                border-radius: 14px !important;
            }

            .hero-cta-mobile .cta-subtext {
                font-size: 1.05rem !important;
                margin-top: 8px !important;
            }

            .section-block {
                padding: 40px 0 !important;
            }

            .section-tag {
                font-size: 0.95rem !important;
                padding: 7px 20px !important;
            }

            .section-title {
                font-size: 2.65rem !important;
                line-height: 1.25 !important;
                margin-bottom: 22px !important;
                max-width: 980px !important;
                margin-left: auto !important;
                margin-right: auto !important;
            }

            .problem-card-grid {
                gap: 28px !important;
                margin-top: 28px !important;
            }

            .problem-item {
                padding: 32px 34px !important;
                border-radius: 20px !important;
            }

            .problem-header-row {
                gap: 16px !important;
                margin-bottom: 14px !important;
            }

            .problem-number {
                min-width: 44px !important;
                height: 44px !important;
                font-size: 1.15rem !important;
                border-radius: 12px !important;
            }

            .problem-text h4 {
                font-size: 1.7rem !important;
                margin-bottom: 8px !important;
            }

            .problem-text p {
                font-size: 1.22rem !important;
                line-height: 1.62 !important;
            }

            .problem-item img,
            .problem-item video,
            .problem-item .media-placeholder-card {
                border-radius: 16px !important;
                margin: 18px 0 !important;
            }

            .problem-item .btn-cta,
            .problem-item .btn-cta-sm {
                font-size: 1.18rem !important;
                padding: 16px 36px !important;
                max-width: 520px !important;
                border-radius: 12px !important;
                margin-top: 18px !important;
            }

            .transition-box {
                padding: 28px 32px !important;
                font-size: 1.28rem !important;
                line-height: 1.65 !important;
                border-radius: 18px !important;
            }

            .solution-card {
                padding: 36px 36px !important;
                border-radius: 20px !important;
            }

            .solution-card h3 {
                font-size: 1.85rem !important;
            }

            .solution-card p {
                font-size: 1.22rem !important;
                line-height: 1.62 !important;
            }

            .sol-badge {
                font-size: 0.95rem !important;
                padding: 8px 18px !important;
            }

            .how-to-steps {
                gap: 16px !important;
                margin-top: 24px !important;
            }

            .step-row {
                padding: 22px 24px !important;
                border-radius: 14px !important;
            }

            .step-num {
                width: 38px !important;
                height: 38px !important;
                font-size: 1.15rem !important;
            }

            .step-text {
                font-size: 1.22rem !important;
            }

            .pricing-card {
                padding: 36px 36px !important;
                border-radius: 20px !important;
            }

            .pricing-card h3 {
                font-size: 1.85rem !important;
            }

            .package-item {
                padding: 24px 26px !important;
                border-radius: 14px !important;
            }

            .package-item h4 {
                font-size: 1.4rem !important;
            }

            .pkg-price {
                font-size: 1.75rem !important;
            }

            .pkg-desc {
                font-size: 1.1rem !important;
            }

            .warning-box {
                padding: 26px 30px !important;
                border-radius: 16px !important;
            }

            .warning-box h3 {
                font-size: 1.45rem !important;
            }

            .warning-box p {
                font-size: 1.15rem !important;
                line-height: 1.6 !important;
            }

            .crm-container-box {
                padding: 40px 40px !important;
                border-radius: 22px !important;
                max-width: 860px !important;
                margin: 0 auto !important;
            }

            .crm-container-box h3 {
                font-size: 1.75rem !important;
            }

            .crm-container-box p {
                font-size: 1.18rem !important;
            }
        }

        /* --- LARGE DESKTOP SCREEN (min-width: 1280px): MAXIMUM PROMINENCE --- */
        @media (min-width: 1280px) {
            html {
                font-size: 19px;
            }

            .container {
                max-width: 1180px !important;
                padding: 0 42px !important;
            }

            .hero-text-col .main-headline {
                font-size: 3.25rem !important;
                line-height: 1.18 !important;
                max-width: 1080px !important;
            }

            .hero-text-col .sub-headline {
                font-size: 1.4rem !important;
                line-height: 1.62 !important;
                max-width: 960px !important;
            }

            .section-title {
                font-size: 2.95rem !important;
                max-width: 1080px !important;
            }

            .problem-text h4 {
                font-size: 1.85rem !important;
            }

            .problem-text p {
                font-size: 1.3rem !important;
                line-height: 1.65 !important;
            }

            .problem-item {
                padding: 36px 42px !important;
            }
        }

        

        

        

        @media (min-width: 1024px) {
            

            
        }
    
        /* ============================================================
           OVERLAY MODAL (ALMOST FULL-HEIGHT SCREEN, PRELOADED FORM)
           ============================================================ */
        .order-modal-backdrop {
            display: flex; /* Keep in render tree so iframe loads immediately on page load! */
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(10, 15, 29, 0.82);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            z-index: 999999;
            align-items: center;
            justify-content: center;
            padding: clamp(4px, 1.5vh, 12px) clamp(6px, 2vw, 14px);
            box-sizing: border-box;
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
            transition: opacity 0.22s ease-in-out, visibility 0.22s ease-in-out;
        }

        .order-modal-backdrop.active {
            opacity: 1;
            visibility: visible;
            pointer-events: auto;
        }

        .order-modal-dialog {
            background: #ffffff;
            width: 100%;
            max-width: 620px;
            height: 96vh;
            height: 96dvh;
            max-height: 98vh;
            border-radius: 16px;
            box-shadow: 0 25px 60px -10px rgba(0, 0, 0, 0.7), 0 0 0 1px rgba(255, 255, 255, 0.15);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
            transform: scale(0.96) translateY(8px);
            animation: overlayModalPopIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        @keyframes overlayModalPopIn {
            from {
                opacity: 0;
                transform: scale(0.96) translateY(8px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .order-modal-header {
            background: linear-gradient(135deg, #047857 0%, #064e3b 100%);
            color: #ffffff;
            padding: 8px 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
            border-bottom: 2px solid var(--citrus-yellow);
            flex-shrink: 0;
            z-index: 2;
        }

        .order-modal-header-content {
            display: flex;
            flex-direction: column;
            gap: 1px;
        }

        .order-modal-title {
            font-family: 'Outfit', sans-serif;
            font-size: clamp(0.95rem, 2.7vw, 1.15rem);
            font-weight: 800;
            letter-spacing: 0.3px;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .order-modal-subtitle {
            font-size: clamp(0.72rem, 2.1vw, 0.84rem);
            color: #fef08a;
            font-weight: 700;
            line-height: 1.35;
            margin-top: 3px;
        }

        .order-modal-subtitle strong {
            color: #ffffff;
            text-decoration: underline;
        }

        .order-modal-close-wrap {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .order-modal-close {
            background: rgba(255, 255, 255, 0.22);
            border: 1px solid rgba(255, 255, 255, 0.4);
            color: #ffffff;
            font-size: 1.4rem;
            font-weight: 700;
            line-height: 1;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s, transform 0.15s;
            flex-shrink: 0;
        }

        .order-modal-close:hover {
            background: rgba(220, 38, 38, 0.85);
            transform: scale(1.08);
        }

        .order-modal-body {
            position: relative;
            flex: 1;
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            padding: 0;
        }

        /* Dedicated Loading State inside Modal */
        .modal-form-loader {
            position: absolute;
            inset: 0;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 10;
            padding: 20px;
            text-align: center;
            transition: opacity 0.25s ease, visibility 0.25s ease;
        }

        .modal-form-loader.hidden {
            opacity: 0;
            visibility: hidden;
            pointer-events: none;
        }

        .loader-spinner {
            width: 38px;
            height: 38px;
            border: 3.5px solid #e2e8f0;
            border-top: 3.5px solid #047857;
            border-radius: 50%;
            animation: spin 0.85s linear infinite;
            margin-bottom: 10px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loader-text {
            font-family: 'Outfit', sans-serif;
            font-size: 1.05rem;
            font-weight: 800;
            color: #047857;
            margin-bottom: 3px;
        }

        .loader-sub {
            font-size: 0.8rem;
            color: #64748b;
            font-weight: 600;
        }

        .order-modal-body iframe {
            width: 100%;
            height: 100%;
            flex: 1;
            border: 0;
            display: block;
            background: #ffffff;
        }

        .order-modal-trust-bar {
            background: #f0fdf4;
            border-top: 1px solid #bbf7d0;
            padding: 6px 12px;
            display: flex;
            align-items: center;
            justify-content: space-around;
            font-size: 0.72rem;
            font-weight: 700;
            color: #166534;
            text-align: center;
            flex-shrink: 0;
            gap: 6px;
        }

        /* ============================================================
           HERBAL SCIENCE & MULLEIN TEA COMPARISON SECTION
           ============================================================ */
        .mullein-compare-section {
            background: linear-gradient(180deg, #f0fdf4 0%, #ffffff 100%);
            border-radius: var(--radius-lg);
            border: 1.5px solid #a7f3d0;
            padding: 24px 16px;
            margin: 24px 0;
            box-shadow: 0 10px 25px -5px rgba(4, 120, 87, 0.08);
        }
        .mechanism-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 14px;
            margin: 18px 0;
        }
        .mechanism-card {
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-left: 4px solid var(--primary-green);
            border-radius: 12px;
            padding: 16px;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
            text-align: left;
        }
        .mechanism-card h4 {
            font-size: 1.02rem;
            color: var(--primary-green-dark);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .mechanism-card p {
            font-size: 0.86rem;
            color: var(--text-sub);
            line-height: 1.48;
        }
        .mech-badge {
            display: inline-block;
            background: #ecfdf5;
            color: #065f46;
            font-size: 0.72rem;
            font-weight: 800;
            padding: 2px 8px;
            border-radius: 4px;
            border: 1px solid #a7f3d0;
            text-transform: uppercase;
            margin-bottom: 6px;
            letter-spacing: 0.4px;
        }
        .compare-table-wrapper {
            margin-top: 18px;
            background: #ffffff;
            border-radius: 12px;
            border: 1.5px solid #bbf7d0;
            overflow: hidden;
        }
        .compare-table-header {
            background: linear-gradient(135deg, #047857 0%, #064e3b 100%);
            color: #ffffff;
            padding: 12px 14px;
            text-align: center;
            font-weight: 800;
            font-size: 0.95rem;
            letter-spacing: 0.4px;
        }
        .respira-quality-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 12px;
            padding: 16px;
            background: #ffffff;
        }
        @media (min-width: 600px) {
            .respira-quality-grid {
                grid-template-columns: 1fr 1fr;
            }
        }
        .quality-card {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 10px;
            padding: 14px;
            text-align: left;
        }
        .quality-card-title {
            font-weight: 800;
            color: #047857;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.92rem;
        }
        .quality-card-desc {
            font-size: 0.84rem;
            color: #334155;
            line-height: 1.45;
            margin: 0;
        }
        @media (min-width: 768px) {
            .mullein-compare-section {
                padding: 32px 24px;
            }
            .mechanism-grid {
                grid-template-columns: repeat(3, 1fr);
                gap: 16px;
            }
            .compare-col {
                padding: 18px 16px;
                font-size: 0.9rem;
            }
        }
    </style>
</head>

<body>
    <div class="top-bar" onclick="scrollToForm()"><span>SPECIAL DISCOUNT ENDS IN</span> <span class="timer-box"
            id="topTimer">00:14:55</span></div>
    <div class="container">
        <section class="hero">
            <div class="hero-grid">
                <div class="hero-text-col">
                    <div onclick="scrollToForm()">
                        <span class="hero-pill-badge"><span class="badge-live-dot"></span> DETOX WITH NOVA &bull; RESPIRA HERBAL
                            WELLNESS TEA</span>
                    </div>
                    <h1 class="main-headline">FREE YOURSELF FROM <span style="color: red;">ASTHMA </span>AND <span
                            class="green">LIVE FREE FOREVER.</span></h1>
                    <p class="sub-headline">If you experience recurring respiratory symptoms, make your overall
                        respiratory wellness a daily priority. <span
                            style="font-weight: bold; color: green;">RESPIRA</span> is a herbal tea that can be
                        incorporated into a
                        personal wellness routine.</p>


                    
                    <div class="hero-scarcity-row" onclick="scrollToForm()">
                        <span class="scarcity-dot"></span>
                        <span>ONLY 14 BOXES LEFT FOR PAY ON DELIVERY TODAY</span>
                    </div>
                    <div class="hero-cta-desktop">
                        <a href="#orderFormSection" class="btn-cta"><span>ORDER RESPIRA NOW</span></a>
                        <p class="cta-subtext">Free Delivery Nationwide &bull; Pay On Delivery</p>
                    </div>
                </div>
                <div class="hero-media-col">
                    <div class="hero-image-card" onclick="scrollToForm()">
                        <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219332/asthma1.gif"
                            alt="A person taking a calm, deep breath in fresh morning air with a warm cup of Respira Herbal Tea for asthma and airway comfort."
                            style="width:100%;display:block;" loading="lazy">
                        <div class="hero-image-overlay-badge">
                            <span class="badge-icon"><svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                    stroke="currentColor" stroke-width="2.5">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                </svg></span>
                            <span>NAFDAC Certified &bull; 100% Organic</span>
                        </div>
                    </div>
                    <div class="hero-cta-mobile">
                        <a href="#orderFormSection" class="btn-cta"><span>ORDER RESPIRA NOW</span></a>
                        <p class="cta-subtext">Free Delivery Nationwide &bull; Pay On Delivery</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="section-block">
            <div style="text-align:center" onclick="scrollToForm()"><span class="section-tag">WHEN BREATHING PROBLEMS
                    KEEP GETTING YOUR ATTENTION</span></div>
            <h2 class="section-title">WHEN BREATHING PROBLEMS KEEP GETTING <span class="green">YOUR ATTENTION</span>
            </h2>
            <div class="problem-card-grid">
                <div class="problem-item">
                    <div class="problem-header-row"><span class="problem-number">01</span>
                        <div class="problem-text">
                            <h4>RECURRING RESPIRATORY DISCOMFORT</h4>
                            <p>Respiratory discomfort that comes back repeatedly disrupts your daily life and peace of
                                mind.</p>
                        </div>
                    </div>
                    <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219339/asthma2.gif"
                        alt="A person pausing activity due to airway discomfort and recurring breathing symptoms."
                        style="width:100%;border-radius:12px;display:block;margin:12px 0;border:2px solid #a7f3d0;"
                        loading="lazy">
                    <a href="#orderFormSection" class="btn-cta btn-cta-sm"><span>ORDER NOW</span></a>
                </div>
                <div class="problem-item">
                    <div class="problem-header-row"><span class="problem-number">02</span>
                        <div class="problem-text">
                            <h4>WORRY ABOUT YOUR BREATHING</h4>
                            <p>When you find yourself regularly worrying about your breathing, it is time to take your
                                respiratory wellness more seriously.</p>
                        </div>
                    </div>
                    <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219344/asthma3.gif"
                        alt="Concern over family member's breathing difficulties and chest tightness."
                        style="width:100%;border-radius:12px;display:block;margin:12px 0;border:2px solid #a7f3d0;"
                        loading="lazy">
                    <a href="#orderFormSection" class="btn-cta btn-cta-sm"><span>ORDER NOW</span></a>
                </div>
                <div class="problem-item">
                    <div class="problem-header-row"><span class="problem-number">03</span>
                        <div class="problem-text">
                            <h4>DISRUPTION TO EVERYDAY ACTIVITIES</h4>
                            <p>Respiratory symptoms that interrupt your work, social life, or exercise can be
                                frustrating and limiting.</p>
                        </div>
                    </div>
                    <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219329/asthma4.gif"
                        alt="A person dealing with shortness of breath and heavy chest tightness during daily activities."
                        style="width:100%;border-radius:12px;display:block;margin:12px 0;border:2px solid #a7f3d0;"
                        loading="lazy">
                    <a href="#orderFormSection" class="btn-cta btn-cta-sm"><span>ORDER NOW</span></a>
                </div>
                <div class="problem-item">
                    <div class="problem-header-row"><span class="problem-number">04</span>
                        <div class="problem-text">
                            <h4>DEPENDENCE ON CARRYING MEDICATION</h4>
                            <p>Always having to carry your inhaler or medication everywhere serves as a constant
                                reminder of your respiratory condition.</p>
                        </div>
                    </div>
                    <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219338/asthma5.gif"
                        alt="A person dealing with acute breathing anxiety and seeking long-term respiratory wellness support."
                        style="width:100%;border-radius:12px;display:block;margin:12px 0;border:2px solid #a7f3d0;"
                        loading="lazy">
                    <a href="#orderFormSection" class="btn-cta btn-cta-sm"><span>ORDER NOW</span></a>
                </div>
            </div>
            <div class="transition-box">
                <p><strong>Don&#39;t ignore persistent or worsening symptoms.</strong><br>Get appropriate medical care
                    <em>and</em> take your overall respiratory wellness seriously.
                </p>
            </div>
        </section>

        <section class="section-block">
            <div style="text-align:center" onclick="scrollToForm()"><span class="section-tag">A SIMPLE HERBAL WELLNESS
                    ROUTINE</span></div>
            <h2 class="section-title">A SIMPLE <span class="green">HERBAL WELLNESS ROUTINE</span></h2>
            <div class="solution-grid">
                <div class="solution-card" onclick="scrollToForm()">
                    <h3>RESPIRA HERBAL WELLNESS TEA</h3>
                    <p>Respira can be incorporated into your daily wellness routine as a warm herbal tea. It works
                    alongside, <strong>not instead of</strong>, any prescribed medical care you receive.</p>
                    <div
                        style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:8px 10px;margin:10px 0;font-size:0.85rem;color:#856404;font-weight:700">
                        MEDICAL CARE + HEALTHY HABITS + DAILY WELLNESS: all together.</div>

                </div>
                <div class="solution-media-col">
                    <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791219336/asthma6.gif"
                        alt="A person enjoying a calm morning with a warm cup of Respira herbal tea for open, comfortable airways."
                        style="width:100%;border-radius:12px;display:block;margin:12px 0;border:2px solid #a7f3d0;"
                        loading="lazy">
                    <a href="#orderFormSection" class="btn-cta btn-cta-md" style="margin-top:14px"><span>ORDER RESPIRA
                            NOW</span></a>
                </div>
            </div>
        </section>

        <!-- ================= HERBAL SCIENCE & AIRWAY RECOVERY SECTION ================= -->
        <section class="section-block">
            <div class="mullein-compare-section">
                <div style="text-align:center" onclick="scrollToForm()">
                    <span class="mech-badge">HERBAL SCIENCE &amp; AIRWAY CLEARANCE</span>
                </div>
                <h2 class="section-title" style="margin-top:6px;font-size:clamp(1.2rem,3.8vw,1.75rem)">
                    HOW AIRWAY SUPPORT WORKS: <span class="green">THE POWER OF RESPIRA</span>
                </h2>
                <p style="text-align:center;font-size:clamp(0.85rem,2.4vw,0.96rem);color:var(--text-sub);margin-bottom:16px;font-weight:600">
                    How natural botanical extracts dissolve stubborn chest catarrh, calm whistling wheezing, and relax tight airways so you can breathe freely.
                </p>

                <!-- 3 Mechanism Cards -->
                <div class="mechanism-grid">
                    <div class="mechanism-card">
                        <span class="mech-badge">01 &bull; AIRWAY CLEARANCE</span>
                        <h4>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.5"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                            Melts Trapped Chest Phlegm
                        </h4>
                        <p>Respira quickly dissolves thick, sticky mucus clogging your air passages, allowing you to cough it out effortlessly and take full, clear breaths without throat strain.</p>
                    </div>

                    <div class="mechanism-card">
                        <span class="mech-badge">02 &bull; CALMS IRRITATION</span>
                        <h4>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            Calms Wheezing &amp; Dry Cough
                        </h4>
                        <p>Rich in protective herbal extracts that soothe sensitive throat and chest linings, calming recurring coughing spells and scratchy chest irritation.</p>
                    </div>

                    <div class="mechanism-card">
                        <span class="mech-badge">03 &bull; CHEST RELAXATION</span>
                        <h4>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
                            Relaxes Tight Chest Spasms
                        </h4>
                        <p>Natural herbs help relax constricted chest muscles and ease spasm tension, removing heavy, suffocating pressure so you sleep peacefully and breathe without fear.</p>
                    </div>
                </div>

                <!-- Quality Box -->
                <div class="compare-table-wrapper">
                    <div class="compare-table-header">
                        WHY THOUSANDS OF NIGERIANS TRUST RESPIRA HERBAL CLEANSER
                    </div>
                    <div class="respira-quality-grid">
                        <div class="quality-card">
                            <div class="quality-card-title">
                                <span>🌿</span> 100% Pure Organic Herbs
                            </div>
                            <p class="quality-card-desc">Formulated with pure botanical ingredients. Zero harsh chemicals, artificial stimulants, or synthetic preservatives. Gentle on the stomach for daily morning use.</p>
                        </div>
                        <div class="quality-card">
                            <div class="quality-card-title">
                                <span>🔬</span> Tested &amp; NAFDAC Approved
                            </div>
                            <p class="quality-card-desc">Fully registered under NAFDAC Reg. No. A7-100346L. Every production batch is certified for clinical purity, hygiene, and active botanical strength.</p>
                        </div>
                        <div class="quality-card">
                            <div class="quality-card-title">
                                <span>☕</span> Sealed Pyramid Teabags
                            </div>
                            <p class="quality-card-desc">No tedious boiling of roots or messy straining of loose leaves. Simply steep one ready-to-use pyramid teabag in hot water for 5 minutes and sip warm.</p>
                        </div>
                        <div class="quality-card">
                            <div class="quality-card-title">
                                <span>🚚</span> Pay On Delivery Nationwide
                            </div>
                            <p class="quality-card-desc">Fast 24 to 48-hour delivery across all 36 states. You only pay cash or transfer to the dispatch rider upon receiving and inspecting your parcel.</p>
                        </div>
                    </div>
                </div>

                <div style="text-align:center;margin-top:16px">
                    <a href="#orderFormSection" class="btn-cta btn-cta-md" style="display:inline-flex;max-width:380px;margin:0 auto"><span>CLAIM YOUR RESPIRA TEA TODAY</span></a>
                </div>
            </div>
        </section>

        <section class="section-block">
            <div style="text-align:center" onclick="scrollToForm()"><span class="section-tag">HOW TO USE</span></div>
            <h2 class="section-title">HOW TO USE <span class="green">RESPIRA</span></h2>
            <div class="how-to-steps">
                <div class="step-row"><span class="step-num">1</span><span class="step-text">Boil <strong>200ml of
                            water</strong></span></div>
                <div class="step-row"><span class="step-num">2</span><span class="step-text">Add <strong>one Respira tea
                            bag</strong></span></div>
                <div class="step-row"><span class="step-num">3</span><span class="step-text">Steep for <strong>5 to 10
                            minutes</strong></span></div>
                <div class="step-row"><span class="step-num">4</span><span class="step-text">Enjoy as part of your
                        <strong>daily wellness routine</strong></span></div>
            </div>
            <div class="pricing-card" style="margin-top:20px">
                <h3
                    style="text-align:center;color:var(--primary-green-dark);font-size:1.3rem;font-weight:900;margin-bottom:4px">
                    SPECIAL DISCOUNT PACKAGES</h3>
                <p style="text-align:center;font-size:0.85rem;color:var(--text-sub);font-weight:600;margin-bottom:12px">
                    Free Delivery nationwide : Pay on Delivery:</p>
                <div class="package-grid">
                    <div class="package-item" onclick="scrollToForm()">
                        <div class="package-info">
                            <h4>1 BOX RESPIRA (30 Teabags)</h4>
                            <p>1 Month Starter Pack</p>
                        </div>
                        <div class="package-price">&#8358;21,500</div>
                    </div>
                    <div class="package-item popular" onclick="scrollToForm()"><span class="popular-badge">MOST
                            POPULAR</span>
                        <div class="package-info">
                            <h4>2 BOXES RESPIRA (60 Teabags)</h4>
                            <p>2 Months Full Wellness</p>
                        </div>
                        <div class="package-price">&#8358;35,000</div>
                    </div>
                    <div class="package-item" onclick="scrollToForm()">
                        <div class="package-info">
                            <h4>3 BOXES RESPIRA (90 Teabags)</h4>
                            <p>3 Months Complete Reset</p>
                        </div>
                        <div class="package-price">&#8358;45,000</div>
                    </div>
                    <div class="package-item" onclick="scrollToForm()">
                        <div class="package-info">
                            <h4>4 BOXES + 1 FREE BOX</h4>
                            <p>Family / Ultimate Pack</p>
                        </div>
                        <div class="package-price">&#8358;55,000</div>
                    </div>
                </div>
                <a href="#orderFormSection" class="btn-cta" style="margin-top:14px"><span>ORDER NOW</span></a>
            </div>
            <div class="safety-note"><strong>Important:</strong> Respira is a herbal wellness tea. It does not replace
                your prescribed asthma medication or medical treatment. If symptoms worsen, seek medical attention.
            </div>
        </section>

        <section class="section-block">
            <div style="text-align:center" onclick="scrollToForm()"><span class="section-tag">REAL CUSTOMER
                    REVIEWS</span></div>
            <h2 class="section-title">REAL FEEDBACK FROM <span class="green">CUSTOMERS</span></h2>
            <p
                style="text-align:center;font-size:clamp(0.85rem,2.4vw,0.95rem);color:var(--text-sub);margin-bottom:10px;font-weight:600">
                <strong>Swipe left/right</strong> to view reviews. <strong>Tap to expand</strong>!
            </p>
            <div class="carousel-wrapper" id="waCarousel">
                <button class="carousel-nav-btn prev-btn" onclick="prevSlide()" aria-label="Previous">&#8249;</button>
                <div class="carousel-track-container">
                    <div class="carousel-track" id="carouselTrack">
                        <div class="carousel-slide"><img
                                src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791218271/whatsapp3.webp"
                                alt="Customer Review 1" onclick="openLightbox(this.src)">
                            <p class="carousel-caption">"I started Respira as part of my morning routine and I really enjoy having it every day."</p>
                            <div class="zoom-hint">Tap to zoom</div>
                        </div>
                        <div class="carousel-slide"><img
                                src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791218269/whatsapp2.webp"
                                alt="Customer Review 2" onclick="openLightbox(this.src)">
                            <p class="carousel-caption">"Respira cleared all black phlegm and calmed chest wheezing!"</p>
                            <div class="zoom-hint">Tap to zoom</div>
                        </div>
                        <div class="carousel-slide"><img
                                src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791218266/whatsapp1.webp"
                                alt="Customer Review 3" onclick="openLightbox(this.src)">
                            <p class="carousel-caption">"My breathing feels much more comfortable. I use Respira every morning!"</p>
                            <div class="zoom-hint">Tap to zoom</div>
                        </div>
                    </div>
                </div>
                <button class="carousel-nav-btn next-btn" onclick="nextSlide()" aria-label="Next">&#8250;</button>
                <div class="carousel-dots" id="carouselDots">
                    <span class="carousel-dot active" onclick="goToSlide(0)"></span>
                    <span class="carousel-dot" onclick="goToSlide(1)"></span>
                    <span class="carousel-dot" onclick="goToSlide(2)"></span>
                </div>
            </div>
            <div class="trust-cards-row">
                <div class="trust-card" onclick="scrollToForm()"><span class="icon"><svg width="22" height="22"
                            viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.2" stroke-linecap="round"
                            stroke-linejoin="round">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                        </svg></span>
                    <h4>NAFDAC CERTIFIED</h4>
                    <p>Safe Natural Tea</p>
                </div>
                <div class="trust-card" onclick="scrollToForm()"><span class="icon"><svg width="22" height="22"
                            viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.2" stroke-linecap="round"
                            stroke-linejoin="round">
                            <rect x="1" y="3" width="15" height="13" />
                            <polygon points="16 8 20 8 23 11 23 16 16 16 16 8" />
                            <circle cx="5.5" cy="18.5" r="2.5" />
                            <circle cx="18.5" cy="18.5" r="2.5" />
                        </svg></span>
                    <h4>PAY ON DELIVERY</h4>
                    <p>Pay Cash or Transfer</p>
                </div>
                <div class="trust-card" onclick="scrollToForm()"><span class="icon"><svg width="22" height="22"
                            viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="2.2" stroke-linecap="round"
                            stroke-linejoin="round">
                            <path
                                d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                            <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                            <line x1="12" y1="22.08" x2="12" y2="12" />
                        </svg></span>
                    <h4>100% DISCREET</h4>
                    <p>Nationwide Delivery</p>
                </div>
            </div>
        </section>
        <!-- ================= ORDER ACTION SECTION (FORM IS IN POPUP MODAL) ================= -->
        <section class="section-block" id="orderFormSection" style="padding-bottom:14px;text-align:center">
            <div style="text-align:center;margin-bottom:14px"><span class="section-tag">READY TO ORDER?</span>
                <h2 class="section-title" style="margin-top:6px">CLAIM YOUR DISCOUNT &amp; <span class="green">PLACE YOUR ORDER</span></h2>
            </div>
            <div class="warning-box" style="margin-bottom:18px">
                <h3>PLEASE ORDER ONLY IF READY</h3>
                <p>1. Cash or transfer ready when rider arrives.<br>2. Available at your address in 1 to 4 days.</p>
            </div>
            <div class="order-popup-prompt-card" style="background:#ffffff;border:2px solid var(--primary-green);border-radius:16px;padding:24px 18px;box-shadow:var(--shadow-card);max-width:650px;margin:0 auto;text-align:center">
                <span style="display:inline-block;background:#d1fae5;color:#065f46;font-size:0.78rem;font-weight:800;padding:3px 12px;border-radius:50px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:10px;">⚡ INSTANT CHECKOUT</span>
                <h3 style="color:var(--primary-green-dark);font-size:clamp(1.15rem,3.2vw,1.4rem);font-weight:900;margin-bottom:6px">READY TO EXPERIENCE RESPIRA?</h3>
                <p style="color:var(--text-sub);font-size:clamp(0.85rem,2.4vw,0.95rem);font-weight:600;margin-bottom:16px">Tap the button below to open your order form in full screen &bull; Pay cash or bank transfer when the rider arrives.</p>
                <button type="button" id="finalOrderCtaBtn" class="btn-cta" onclick="openOrderModal()" style="font-size:clamp(1.05rem,3.2vw,1.3rem);padding:16px 28px;width:100%;max-width:440px;margin:0 auto;box-shadow:var(--shadow-red);cursor:pointer;border:none"><span>ORDER NOW</span></button>
                <p class="cta-subtext" style="margin-top:10px;font-size:0.82rem;color:var(--text-muted);font-weight:700">&#128274; Free Delivery Nationwide &bull; Pay On Delivery</p>
            </div>
        </section>

        <!-- Topic Cluster Silo: Internal Linking for SEO -->
        <section class="section-block" style="padding:18px 14px;background:#f0fdf4;border-radius:14px;border:1px solid #bbf7d0;margin:18px auto 14px;max-width:850px;text-align:center;">
            <h4 style="font-size:0.95rem;color:#065f46;font-weight:800;margin-bottom:10px;text-transform:uppercase;letter-spacing:0.5px;">Explore Other Respiratory Solutions</h4>
            <div style="display:flex;flex-wrap:wrap;gap:10px;justify-content:center;font-size:0.85rem;font-weight:700;">
                <a href="smokers.php" style="color:#047857;text-decoration:none;background:#ffffff;padding:10px 16px;border-radius:8px;border:1px solid #a7f3d0;display:inline-flex;align-items:center;gap:6px;box-shadow:0 1px 3px rgba(0,0,0,0.04);">
                    🫁 Smokers Lung Detox Tea &rarr;
                </a>
                <a href="general.php" style="color:#047857;text-decoration:none;background:#ffffff;padding:10px 16px;border-radius:8px;border:1px solid #a7f3d0;display:inline-flex;align-items:center;gap:6px;box-shadow:0 1px 3px rgba(0,0,0,0.04);">
                    🌿 Persistent Cough &amp; Phlegm Flush &rarr;
                </a>
                <a href="index.php" style="color:#047857;text-decoration:none;background:#ffffff;padding:10px 16px;border-radius:8px;border:1px solid #a7f3d0;display:inline-flex;align-items:center;gap:6px;box-shadow:0 1px 3px rgba(0,0,0,0.04);">
                    📦 View Full Herbal Product Catalog &rarr;
                </a>
            </div>
        </section>

        <footer>
            <div style="margin-bottom:12px;">
                <img src="https://res.cloudinary.com/kxvehvqy/image/upload/v1791220684/Detox_With_Nova_Logo_250.png" alt="Detox With Nova Logo" style="height:38px; width:auto; display:inline-block;">
            </div>
            <h4>RESPIRA AOH HERBAL CLEANSER TEA</h4>
            <p>Marketed by: <strong>Detox With Nova</strong> for <strong>Novacare Limited</strong></p>
            <div style="margin:10px 0;display:flex;justify-content:center;gap:14px;flex-wrap:wrap;font-size:0.85rem;">
                <a href="https://www.facebook.com/detoxwithnova" target="_blank" rel="noopener noreferrer" style="color:#047857;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">📘 Facebook: /detoxwithnova</a>
                <a href="https://www.instagram.com/emeraldmarketings/?hl=en" target="_blank" rel="noopener noreferrer" style="color:#047857;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">📸 Instagram: @emeraldmarketings</a>
            </div>
            <div class="footer-links"><a href="#">Privacy Policy</a> | <a href="#">Terms of Service</a> | <a
                    href="#">Return Policy</a></div>
            <p style="font-size:0.75rem;margin-top:6px;opacity:0.8">Disclaimer: Not affiliated with Facebook or Google.
                Individual results may vary. Respira is a herbal wellness tea and is not intended to diagnose, treat,
                cure, or prevent any disease.</p>
        </footer>
    </div>
    <div class="lightbox-modal" id="lightboxModal" onclick="closeLightbox(event)">
        <div class="lightbox-content"><span class="close-lightbox" onclick="closeLightboxDirect()">&times;</span><img
                id="lightboxImg" src="" alt="Expanded View"></div>
    </div>
    <script>
        // Modal & Form State Controller
        // Modal & Form State Controller: Route directly to Smart WhatsApp Drawer
        function openOrderModal(e) {
            if (e && e.preventDefault) e.preventDefault();

            // Detect clicked package to auto-select
            var target = (e && e.currentTarget) ? e.currentTarget : (e && e.target ? e.target : null);
            var pkgVal = '';
            if (target) {
                var text = target.innerText || target.textContent || '';
                if (text.indexOf('1 BOX') !== -1 || text.indexOf('21,500') !== -1) pkgVal = '1 Box: ₦21,500';
                else if (text.indexOf('2 BOXES') !== -1 || text.indexOf('35,000') !== -1) pkgVal = '2 Boxes: ₦35,000 (Most Popular)';
                else if (text.indexOf('3 BOXES') !== -1 || text.indexOf('45,000') !== -1) pkgVal = '3 Boxes: ₦45,000';
                else if (text.indexOf('4 BOXES') !== -1 || text.indexOf('55,000') !== -1) pkgVal = '4 Boxes + 1 Free: ₦55,000';
            }

            var drawer = document.getElementById('respira-wa-drawer');
            var backdrop = document.getElementById('respira-wa-backdrop');
            if (drawer && backdrop) {
                if (pkgVal) {
                    var pkgSel = document.getElementById('respira_wa_pkg');
                    if (pkgSel) pkgSel.value = pkgVal;
                }
                drawer.classList.add('active');
                backdrop.classList.add('active');
                var nameInput = document.getElementById('respira_wa_name');
                if (nameInput) setTimeout(function() { nameInput.focus(); }, 180);
                return;
            }

            if (typeof toggleRespiraWaDrawer === 'function') {
                toggleRespiraWaDrawer(e);
            }
        }

        function closeOrderModalDirect() {
            if (typeof closeRespiraWaDrawer === 'function') {
                closeRespiraWaDrawer();
            }
        }

        function scrollToForm() { const f = document.getElementById('orderFormSection'); if (f) f.scrollIntoView({ behavior: 'smooth' }) }
        let timerMinutes = 15;
        let ts = timerMinutes * 60;
        function updateTimer() { let h = Math.floor(ts / 3600), m = Math.floor((ts % 3600) / 60), s = ts % 60, el = document.getElementById('topTimer'); if (el) el.innerText = (h < 10 ? '0' + h : h) + ':' + (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s); if (ts > 0) ts--; else ts = timerMinutes * 60 }
        setInterval(updateTimer, 1000);
        let cur = 0, tot = 4, track = document.getElementById('carouselTrack'), dots = document.querySelectorAll('.carousel-dot');
        function goToSlide(i) { if (i < 0) i = tot - 1; if (i >= tot) i = 0; cur = i; track.style.transform = 'translateX(-' + (cur * 100) + '%)'; dots.forEach((d, x) => d.classList.toggle('active', x === cur)) }
        function nextSlide() { goToSlide(cur + 1) } function prevSlide() { goToSlide(cur - 1) }
        let sx = 0, ex = 0, wr = document.getElementById('waCarousel');
        wr.addEventListener('touchstart', e => { sx = e.touches[0].clientX }, { passive: true });
        wr.addEventListener('touchend', e => { ex = e.changedTouches[0].clientX; if (sx - ex > 40) nextSlide(); if (ex - sx > 40) prevSlide() }, { passive: true });
        function openLightbox(src) { if (!src) return; document.getElementById('lightboxImg').src = src; document.getElementById('lightboxModal').classList.add('active'); document.body.style.overflow = 'hidden' }
        function closeLightbox(e) { if (e.target.id === 'lightboxModal') closeLightboxDirect() }
        function closeLightboxDirect() { document.getElementById('lightboxModal').classList.remove('active'); document.body.style.overflow = 'auto' }
        document.addEventListener('keydown', e => { if (e.key === 'Escape') { closeOrderModalDirect(); closeLightboxDirect(); } });
        // Fallback handled inside dedicated overlay modal

        // --- Dynamic Media Loader (Images & Videos) ---
        function setupMediaElements() {
            document.querySelectorAll('img[src]').forEach(function (img) {
                if (img.id === 'lightboxImg' || (img.closest && img.closest('.carousel-slide'))) return;
                var src = img.getAttribute('src');
                if (!src || src === '#insert') {
                    // When link is "#insert", show an informative styled card displaying the alt text description
                    var placeholder = document.createElement('div');
                    placeholder.className = 'media-placeholder-card';
                    placeholder.style.cssText = 'background:#f8fafc;border:2px dashed #047857;border-radius:12px;padding:16px 14px;margin:12px 0;text-align:center;box-sizing:border-box;box-shadow:0 2px 8px rgba(0,0,0,0.03);';
                    placeholder.innerHTML = '<span style="display:inline-block;background:#d1fae5;color:#065f46;font-size:0.75rem;font-weight:800;padding:3px 10px;border-radius:50px;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px;">Media Placeholder (Link: #insert)</span>' +
                        '<p style="font-size:clamp(0.85rem,2.2vw,0.92rem);color:#1e293b;font-weight:600;line-height:1.5;margin:6px 0;font-style:italic;">' + (img.alt || 'No description provided') + '</p>' +
                        '<span style="display:inline-block;font-size:0.75rem;color:#64748b;margin-top:4px;">When you replace &quot;#insert&quot; with your image or video link, it will display here immediately.</span>';
                    img.style.display = 'none';
                    img.parentNode.insertBefore(placeholder, img);
                } else if (src.match(/\.(mp4|webm|ogg|mov|m4v)(\?.*)?$/i) || src.indexOf('/video/') !== -1) {
                    // Video link inserted! Transform into responsive playable video element
                    var video = document.createElement('video');
                    video.src = src;
                    video.controls = true;
                    video.playsInline = true;
                    video.style.cssText = img.style.cssText;
                    video.style.width = '100%';
                    video.style.display = 'block';
                    video.style.borderRadius = '12px';
                    video.className = img.className;
                    video.setAttribute('title', img.alt);
                    img.parentNode.replaceChild(video, img);
                } else if (src.indexOf('youtube.com') !== -1 || src.indexOf('youtu.be') !== -1 || src.indexOf('vimeo.com') !== -1) {
                    // Video embed inserted! Transform into responsive iframe
                    var embedUrl = src;
                    if (src.indexOf('watch?v=') !== -1) {
                        embedUrl = src.replace('watch?v=', 'embed/');
                    } else if (src.indexOf('youtu.be/') !== -1) {
                        embedUrl = src.replace('youtu.be/', 'www.youtube.com/embed/');
                    } else if (src.indexOf('vimeo.com/') !== -1 && src.indexOf('player.vimeo.com') === -1) {
                        embedUrl = src.replace('vimeo.com/', 'player.vimeo.com/video/');
                    }
                    var iframe = document.createElement('iframe');
                    iframe.src = embedUrl;
                    iframe.style.width = '100%';
                    iframe.style.height = '315px';
                    iframe.style.borderRadius = '12px';
                    iframe.style.border = '0';
                    iframe.style.margin = '12px 0';
                    iframe.setAttribute('allowfullscreen', 'true');
                    img.parentNode.replaceChild(iframe, img);
                } else {
                    // Real image link inserted! Display immediately
                    img.style.display = 'block';
                }
            });
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', setupMediaElements);
        } else {
            setupMediaElements();
        }

       
    
        // Click & Scroll Listeners for Modal Popup
        document.addEventListener('DOMContentLoaded', function () {
            // All CTA buttons, package items, links trigger the modal popup directly (no jump scroll)
            document.querySelectorAll('a[href="#orderFormSection"], .btn-cta, .package-item, [onclick*="scrollToForm"]').forEach(function (el) {
                el.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    openOrderModal(e);
                });
            });

            // Automatically pop up modal when scrolling reaches the last CTA button for order
            let formModalAutoTriggered = false;

            function triggerModalOnScroll() {
                if (formModalAutoTriggered) return;
                formModalAutoTriggered = true;
                openOrderModal();
            }

            // 1. Direct Scroll Position Listener: checks when scrolling reaches the last CTA button
            function checkLastCtaScroll() {
                if (formModalAutoTriggered) return;
                const lastCta = document.getElementById('finalOrderCtaBtn') || document.querySelector('#orderFormSection .btn-cta');
                if (lastCta) {
                    const rect = lastCta.getBoundingClientRect();
                    // Triggers when the top of the last CTA button enters the viewport
                    if (rect.top <= (window.innerHeight || document.documentElement.clientHeight)) {
                        triggerModalOnScroll();
                    }
                }
            }
            window.addEventListener('scroll', checkLastCtaScroll, { passive: true });
            checkLastCtaScroll();

            // 2. Hardware-accelerated IntersectionObserver directly targeting the last CTA button
            const lastCtaBtn = document.getElementById('finalOrderCtaBtn') || document.querySelector('#orderFormSection .btn-cta');
            if (lastCtaBtn && 'IntersectionObserver' in window) {
                const ctaObserver = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting && !formModalAutoTriggered) {
                            triggerModalOnScroll();
                        }
                    });
                }, { threshold: 0, rootMargin: '0px 0px 0px 0px' });
                ctaObserver.observe(lastCtaBtn);
            }

            // 3. Fallback Inactivity Timer: opens form after 15 seconds if visitor hasn't scrolled or clicked yet
            const AUTO_POPUP_DELAY_MS = 15000;
            setTimeout(function () {
                if (!formModalAutoTriggered) {
                    triggerModalOnScroll();
                }
            }, AUTO_POPUP_DELAY_MS);
        });
    </script>


<?php if (function_exists('tracker_render_whatsapp_button')) { tracker_render_whatsapp_button($angle, $config); } ?>

</body>

</html>