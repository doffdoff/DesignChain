;; DesignChain: Creative Design and Portfolio Showcase Exchange Platform
;; Version: 1.0.0

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-DESIGN-NOT-FOUND (err u2))
(define-constant ERR-ALREADY-PUBLISHED (err u3))
(define-constant ERR-INVALID-STATUS (err u4))
(define-constant ERR-INVALID-REVISION-COUNT (err u5))
(define-constant ERR-INVALID-DESIGN-CATEGORY (err u6))
(define-constant ERR-INVALID-COMPLEXITY (err u7))
(define-constant ERR-INVALID-DESIGN-TITLE (err u8))
(define-constant ERR-INVALID-DESCRIPTION (err u9))

(define-constant MIN-REVISION-COUNT u1)

(define-data-var next-design-id uint u1)

(define-map design-portfolio
    uint
    {
        designer: principal,
        design-title: (string-utf8 50),
        description: (string-utf8 200),
        design-category: (string-utf8 15),
        complexity: (string-utf8 10),
        showcase-status: (string-utf8 15),
        revision-count: uint
    })

(define-private (validate-design-category (design-category (string-utf8 15)))
    (or 
        (is-eq design-category u"Graphic")
        (is-eq design-category u"Web")
        (is-eq design-category u"Product")
        (is-eq design-category u"Interior")
        (is-eq design-category u"Fashion")
        (is-eq design-category u"Architecture")
    ))

(define-private (validate-complexity (complexity (string-utf8 10)))
    (or 
        (is-eq complexity u"Simple")
        (is-eq complexity u"Standard")
        (is-eq complexity u"Complex")
        (is-eq complexity u"Intricate")
        (is-eq complexity u"Masterwork")
    ))

(define-private (validate-text-structure (text (string-utf8 200)) (min-length uint) (max-length uint))
    (let 
        (
            (text-length (len text))
        )
        (and 
            (>= text-length min-length)
            (<= text-length max-length)
        )
    ))

(define-public (showcase-design 
    (design-title (string-utf8 50))
    (description (string-utf8 200))
    (design-category (string-utf8 15))
    (complexity (string-utf8 10))
    (revision-count uint))
    (let
        (
            (design-id (var-get next-design-id))
        )
        (asserts! (validate-text-structure design-title u3 u50) ERR-INVALID-DESIGN-TITLE)
        (asserts! (validate-text-structure description u10 u200) ERR-INVALID-DESCRIPTION)
        (asserts! (>= revision-count MIN-REVISION-COUNT) ERR-INVALID-REVISION-COUNT)
        (asserts! (validate-design-category design-category) ERR-INVALID-DESIGN-CATEGORY)
        (asserts! (validate-complexity complexity) ERR-INVALID-COMPLEXITY)
        
        (map-set design-portfolio design-id {
            designer: tx-sender,
            design-title: design-title,
            description: description,
            design-category: design-category,
            complexity: complexity,
            showcase-status: u"featured",
            revision-count: revision-count
        })
        (var-set next-design-id (+ design-id u1))
        (ok design-id)
    ))

(define-public (hide-design (design-id uint))
    (let
        (
            (design (unwrap! (map-get? design-portfolio design-id) ERR-DESIGN-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get designer design)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get showcase-status design) u"featured") ERR-INVALID-STATUS)
        (ok (map-set design-portfolio design-id (merge design { showcase-status: u"hidden" })))
    ))

(define-read-only (get-design (design-id uint))
    (ok (map-get? design-portfolio design-id)))

(define-read-only (get-designer (design-id uint))
    (ok (get designer (unwrap! (map-get? design-portfolio design-id) ERR-DESIGN-NOT-FOUND))))

(define-read-only (get-total-designs)
    (ok (- (var-get next-design-id) u1)))

(define-read-only (get-showcase-status (design-id uint))
    (ok (get showcase-status (unwrap! (map-get? design-portfolio design-id) ERR-DESIGN-NOT-FOUND))))