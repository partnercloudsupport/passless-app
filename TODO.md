- Create a screen where the user has to agree on the legal basics involved:
  Agree on formats, exchange mechanisms, methods to ensure authenticity, 
  integrity and legibility. Should be a click on a button or box
- When receiving a receipt, start a process with verification steps.
  - Store the actual received content in a database.
  - Verify integrity and authenticity.
  - Verify technical correctness.
  - On any problem, the issuer should be notified.
  - Only after processing these steps, should a receipt be considered verified.
  - Date check, trading partner id and addresses, availability of mandatory or conditionally required data, vat numbers, product and service codes, etc.
  - Price calculation, supplier information
  - Show a bagde indicating whether the receipt has been verified.
- Include vat rates in tax container.
  - Shoud the total VAT per vat rate be included in the receipt?
- Pretty design of receipt details.
- Store receipt signatures on a webservice.
- Exclude logo from receipt model. Call a webservice seperately from the exchange process.
- Make a new receipt enter on the new receipt page (initial route)
- Test everything.
- Get app to run on an iOS simulator. Even before NFC plugin has been implemented.