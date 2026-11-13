
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Contact Us - Foodiz</title>

    <!-- Connect CSS file -->
    <link rel="stylesheet" href="../style.css">
</head>

<body>

    <!-- CONTACT PAGE -->
    <section class="contact-page">

        <!-- Hero Section -->
        <div class="contact-hero">
            <div class="contact-hero-content">
                <p class="contact-subtitle">WE ARE HERE FOR YOU</p>

                <h1>Contact Us</h1>

                <p>
                    Have a question, suggestion or feedback?
                    We'd love to hear from you!
                </p>
            </div>
        </div>


        <!-- Contact Information Cards -->
        <div class="contact-info-section">

            <!-- Email Card -->
            <div class="contact-info-card">
                <span class="contact-icon">✉</span>

                <h3>Email Us</h3>

                <p>Get in touch with our team.</p>

                <a href="mailto:f.boujana@interface3.be">
                    f.boujana@interface3.be
                </a>

                <a href="mailto:l.ndualu@interface3.be">
                    l.ndualu@interface3.be
                </a>

                <a href="mailto:w.boguszewska@interface3.be">
                    w.boguszewska@interface3.be
                </a>

                <a href="mailto:p.patel@interface3.be">
                    p.patel@interface3.be
                </a>
            </div>


            <!-- Mission Card -->
            <div class="contact-info-card">
                <span class="contact-icon">♡</span>

                <h3>Our Mission</h3>

                <p>
                    Foodiz helps you discover recipes, save time
                    and make everyday cooking easier.
                </p>
            </div>


            <!-- Location Card -->
            <div class="contact-info-card">
                <span class="contact-icon">⌖</span>

                <h3>Our Location</h3>

                <p>Interface3, Brussels, Belgium</p>
            </div>

        </div>


        <!-- Contact Form and Message -->
        <div class="contact-main-section">

            <!-- Contact Form -->
            <div class="contact-form-container">

                <h2>Send Us a Message</h2>

                <p>We would be happy to hear from you.</p>

                <form class="contact-form" method="post">

                    <!-- Name -->
                    <div class="contact-form-group">

                        <label for="contact-name">Your Name</label>

                        <input
                            type="text"
                            id="contact-name"
                            name="name"
                            placeholder="Enter your name"
                            required
                        >

                    </div>


                    <!-- Email -->
                    <div class="contact-form-group">

                        <label for="contact-email">Your Email</label>

                        <input
                            type="email"
                            id="contact-email"
                            name="email"
                            placeholder="Enter your email"
                            required
                        >

                    </div>


                    <!-- Subject -->
                    <div class="contact-form-group">

                        <label for="contact-subject">Subject</label>

                        <input
                            type="text"
                            id="contact-subject"
                            name="subject"
                            placeholder="Enter the subject"
                            required
                        >

                    </div>


                    <!-- Message -->
                    <div class="contact-form-group">

                        <label for="contact-message">Your Message</label>

                        <textarea
                            id="contact-message"
                            name="message"
                            rows="5"
                            placeholder="Write your message here..."
                            required
                        ></textarea>

                    </div>


                    <!-- Submit Button -->
                    <button type="submit" class="contact-submit-btn">
                        Send Message
                    </button>

                </form>

            </div>


            <!-- Right Side Message -->
            <div class="contact-message-section">

                <p class="contact-subtitle">LET'S TALK</p>

                <h2>We'd Love to Hear From You!</h2>

                <p>
                    Whether you have a question about recipes,
                    suggestions for Foodiz or simply want to say hello,
                    our team is happy to hear from you.
                </p>

                <div class="contact-highlight">

                    <h3>Foodiz</h3>

                    <p>Less Time Cooking, More Time Living.</p>

                </div>

            </div>

        </div>

    </section>

</body>
</html>
