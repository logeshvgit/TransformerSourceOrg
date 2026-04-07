<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PrintCo — Commercial Printers</title>
  <style>
    :root { --ink: #0f172a; --muted: #64748b; --accent: #0ea5e9; --card: #f8fafc; }
    body { font-family: system-ui, sans-serif; margin: 0; color: var(--ink); line-height: 1.5; }
    header { background: linear-gradient(135deg, #0f172a, #1e3a5f); color: #fff; padding: 1.5rem 2rem; }
    header h1 { margin: 0; font-size: 1.5rem; }
    header p { margin: 0.35rem 0 0; opacity: 0.9; font-size: 0.95rem; }
    main { max-width: 960px; margin: 0 auto; padding: 2rem; }
    h2 { font-size: 1.1rem; margin-top: 2rem; border-bottom: 1px solid #e2e8f0; padding-bottom: 0.35rem; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; }
    .card { background: var(--card); border: 1px solid #e2e8f0; border-radius: 8px; padding: 1rem; }
    .card h3 { margin: 0 0 0.35rem; font-size: 1rem; }
    .card .sku { font-size: 0.75rem; color: var(--muted); }
    .card .price { color: var(--accent); font-weight: 600; margin-top: 0.5rem; }
    form { display: grid; gap: 0.75rem; max-width: 480px; }
    label { font-size: 0.85rem; font-weight: 600; }
    input, textarea, select { width: 100%; padding: 0.5rem 0.65rem; border: 1px solid #cbd5e1; border-radius: 6px; font: inherit; box-sizing: border-box; }
    button { background: var(--accent); color: #fff; border: none; padding: 0.65rem 1.25rem; border-radius: 6px; font-weight: 600; cursor: pointer; }
    button:hover { filter: brightness(1.05); }
    .note { font-size: 0.85rem; color: var(--muted); margin-top: 1rem; }
    footer { padding: 2rem; text-align: center; color: var(--muted); font-size: 0.85rem; }
  </style>
</head>
<body>
  <header>
    <h1>PrintCo</h1>
    <p>Commercial printers — demo guest page (static resource). Use in Experience Cloud or Sites with guest case + Messaging.</p>
  </header>
  <main>
    <section>
      <h2>Featured products</h2>
      <div class="grid" id="products"></div>
    </section>
    <section>
      <h2>Contact support (Web-to-Case)</h2>
      <p class="note">Replace <code>ACTION_URL</code>, <code>ORG_ID</code>, and hidden fields with your org&rsquo;s Web-to-Case endpoint and values from Setup &rarr; Web-to-Case.</p>
      <form action="ACTION_URL" method="POST">
        <input type="hidden" name="orgid" value="ORG_ID" />
        <input type="hidden" name="retURL" value="https://example.com/thanks" />
        <div>
          <label for="name">Name</label>
          <input id="name" name="name" required />
        </div>
        <div>
          <label for="email">Email</label>
          <input id="email" name="email" type="email" required />
        </div>
        <div>
          <label for="phone">Phone</label>
          <input id="phone" name="phone" type="tel" />
        </div>
        <div>
          <label for="subject">Subject</label>
          <input id="subject" name="subject" required />
        </div>
        <div>
          <label for="description">Description</label>
          <textarea id="description" name="description" rows="4" required></textarea>
        </div>
        <button type="submit">Submit case</button>
      </form>
    </section>
    <section>
      <h2>Chat (Embedded Messaging)</h2>
      <p class="note">After you create an <strong>Embedded Service Deployment</strong> (Messaging for In-App and Web), paste the deployment snippet below. Agents receive chats via Omni-Channel when linked to the Messaging channel and queues.</p>
      <div id="embedded-messaging-placeholder" style="min-height: 60px; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 1rem; color: var(--muted);">
        Embedded Messaging script goes here (from Setup &rarr; Embedded Service Deployments).
      </div>
    </section>
  </main>
  <footer>PrintCo demo — not for production use without Web-to-Case and Messaging configuration.</footer>
  <script>
    var products = [
      { sku: 'PC-PRESS-5000', name: 'PrintCo Press 5000', price: '$12,900' },
      { sku: 'PC-WIDE-36', name: 'Wide Format 36"', price: '$8,400' },
      { sku: 'PC-COLOR-A3', name: 'Color Production A3', price: '$5,200' },
      { sku: 'PC-MONO-A4', name: 'Mono Fleet A4', price: '$890' },
      { sku: 'PC-FINISH-BOOK', name: 'Booklet Finisher Pro', price: '$2,100' },
      { sku: 'PC-FIERY-RIP', name: 'Fiery RIP Module', price: '$1,650' },
      { sku: 'PC-TONER-CMYK', name: 'Toner Set CMYK', price: '$420' },
      { sku: 'PC-FUSER-KIT', name: 'Fuser Maintenance Kit', price: '$310' },
      { sku: 'PC-MEDIA-GLOSS', name: 'Gloss Media Roll', price: '$180' },
      { sku: 'PC-SLA-GOLD', name: 'Gold SLA Add-on', price: '$2,400/yr' }
    ];
    var el = document.getElementById('products');
    products.forEach(function (p) {
      var d = document.createElement('div');
      d.className = 'card';
      d.innerHTML = '<div class="sku">' + p.sku + '</div><h3>' + p.name + '</h3><div class="price">' + p.price + '</div>';
      el.appendChild(d);
    });
  </script>
</body>
</html>
