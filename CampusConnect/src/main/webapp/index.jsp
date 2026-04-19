<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>CampusConnect - Connect with Your Campus</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/global.css">
    <style>
        /* minimal overrides – everything else uses Bootstrap utilities */
        .hero-section {
            min-height: 90vh;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        .hero-content {
            position: relative;
            z-index: 10;
        }
        .hero-title {
            font-weight: 800;
            background: linear-gradient(135deg, #00e5ff, #80ffff);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
        }
        .feature-card {
            background: rgba(17, 17, 17, 0.8);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(0, 229, 255, 0.2);
            border-radius: 24px;
            padding: 2rem;
            transition: all 0.4s cubic-bezier(0.2, 0.9, 0.4, 1.1);
            height: 100%;
        }
        .feature-card:hover {
            transform: translateY(-8px) rotateX(5deg) rotateY(5deg);
            border-color: var(--aqua, #0dcaf0);
            box-shadow: 0 20px 30px -15px rgba(0, 229, 255, 0.3);
        }
        .feature-icon {
            font-size: 2.5rem;
            color: var(--aqua, #0dcaf0);
            margin-bottom: 1rem;
            transition: transform 0.3s;
        }
        .stats-section {
            background: var(--bg-card, #1e1e1e);
            border-radius: 30px;
            padding: 3rem 1rem;
            margin: 3rem 0;
            border: 1px solid rgba(0, 229, 255, 0.2);
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--aqua, #0dcaf0);
            transition: all 0.3s;
        }
        .stat-item:hover .stat-number {
            transform: scale(1.1);
            text-shadow: 0 0 10px rgba(0, 229, 255, 0.5);
        }
        .testimonial-card {
            background: var(--bg-elevated, #2a2a2a);
            border-radius: 20px;
            padding: 1.5rem;
            border: 1px solid rgba(0, 229, 255, 0.1);
            transition: all 0.3s ease;
            height: 100%;
        }
        .testimonial-card:hover {
            transform: translateY(-5px);
            border-color: var(--aqua, #0dcaf0);
        }
        .cta-section {
            background: linear-gradient(135deg, rgba(0, 229, 255, 0.1), rgba(0, 180, 216, 0.05));
            border-radius: 30px;
            padding: 3rem 1rem;
            text-align: center;
            margin: 3rem 0;
        }
        #canvas-container {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            pointer-events: none;
        }
        /* responsive touch adjustments */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.8rem !important;
            }
            .feature-card, .testimonial-card {
                padding: 1.25rem;
            }
            .stat-number {
                font-size: 2rem;
            }
            .stats-section {
                padding: 2rem 0.5rem;
            }
        }
        @media (max-width: 576px) {
            .hero-title {
                font-size: 2.2rem !important;
            }
            .btn-lg {
                padding: 0.5rem 1rem;
                font-size: 1rem;
            }
        }
    </style>
</head>
<body class="bg-dark text-white">

    <!-- Navbar with responsive toggler -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark bg-dark border-bottom border-secondary">
        <div class="container">
            <a class="navbar-brand" href="index.jsp"><i class="fas fa-graduation-cap me-2"></i>CampusConnect</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain" aria-controls="navbarMain" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarMain">
                <div class="navbar-nav ms-auto">
                    <a class="nav-link" href="index.jsp">Home</a>
                    <a class="nav-link" href="login.jsp">Login</a>
                    <a class="nav-link" href="register.jsp">Register</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero with 3D canvas -->
    <div class="hero-section">
        <div id="canvas-container"></div>
        <div class="container hero-content py-5">
            <div class="row justify-content-center">
                <div class="col-12 col-md-10 col-lg-8">
                    <h1 class="hero-title display-2 fw-bold mb-4">CampusConnect</h1>
                    <p class="lead text-white-50 mb-4">The social network built for students, by students. Connect, share, and grow together.</p>
                    <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center">
                        <a href="login.jsp" class="btn btn-primary btn-lg px-4">Get Started</a>
                        <a href="register.jsp" class="btn btn-outline-primary btn-lg px-4">Join Now</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container my-5">
        <!-- Features with responsive row-cols -->
        <div class="row row-cols-1 row-cols-md-3 g-4 mb-5">
            <div class="col">
                <div class="feature-card text-center h-100">
                    <div class="feature-icon"><i class="fas fa-comments"></i></div>
                    <h5 class="text-aqua">Real-time Chat</h5>
                    <p class="text-white-50">Connect instantly with your campus friends through our modern messaging system.</p>
                </div>
            </div>
            <div class="col">
                <div class="feature-card text-center h-100">
                    <div class="feature-icon"><i class="fas fa-newspaper"></i></div>
                    <h5 class="text-aqua">Campus Feed</h5>
                    <p class="text-white-50">Share moments, post updates, and stay updated with what's happening around campus.</p>
                </div>
            </div>
            <div class="col">
                <div class="feature-card text-center h-100">
                    <div class="feature-icon"><i class="fas fa-user-friends"></i></div>
                    <h5 class="text-aqua">Find Friends</h5>
                    <p class="text-white-50">Discover and follow other students, build your campus network.</p>
                </div>
            </div>
        </div>

        <!-- Stats Section -->
        <div class="stats-section text-center">
            <div class="row row-cols-1 row-cols-md-3 g-4">
                <div class="col stat-item">
                    <div class="stat-number">500+</div>
                    <p class="text-secondary mb-0">Active Students</p>
                </div>
                <div class="col stat-item">
                    <div class="stat-number">1000+</div>
                    <p class="text-secondary mb-0">Daily Posts</p>
                </div>
                <div class="col stat-item">
                    <div class="stat-number">50+</div>
                    <p class="text-secondary mb-0">Campus Clubs</p>
                </div>
            </div>
        </div>

        <!-- Testimonials -->
        <h3 class="text-aqua text-center mb-4">What Students Say</h3>
        <div class="row row-cols-1 row-cols-md-3 g-4 mb-5">
            <div class="col">
                <div class="testimonial-card h-100">
                    <i class="fas fa-quote-left text-aqua mb-3"></i>
                    <p class="text-white-50">CampusConnect helped me find study partners and make lifelong friends. The chat feature is amazing!</p>
                    <div class="mt-3">
                        <i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i>
                    </div>
                    <p class="mb-0 mt-2 fw-bold">— Alex Johnson</p>
                    <small class="text-secondary">Computer Science, 2025</small>
                </div>
            </div>
            <div class="col">
                <div class="testimonial-card h-100">
                    <i class="fas fa-quote-left text-aqua mb-3"></i>
                    <p class="text-white-50">The best platform to stay connected with campus events and announcements. Highly recommended!</p>
                    <div class="mt-3">
                        <i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i>
                    </div>
                    <p class="mb-0 mt-2 fw-bold">— Maria Garcia</p>
                    <small class="text-secondary">Business Administration, 2026</small>
                </div>
            </div>
            <div class="col">
                <div class="testimonial-card h-100">
                    <i class="fas fa-quote-left text-aqua mb-3"></i>
                    <p class="text-white-50">I love how easy it is to share photos and videos from campus events. Great community!</p>
                    <div class="mt-3">
                        <i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star text-aqua"></i><i class="fas fa-star-half-alt text-aqua"></i>
                    </div>
                    <p class="mb-0 mt-2 fw-bold">— David Kim</p>
                    <small class="text-secondary">Engineering, 2024</small>
                </div>
            </div>
        </div>

        <!-- CTA Section -->
        <div class="cta-section">
            <h2 class="fw-bold text-aqua mb-3">Ready to Join the Community?</h2>
            <p class="text-white-50 mb-4">Create your account today and start connecting with your campus.</p>
            <a href="register.jsp" class="btn btn-primary btn-lg px-5">Sign Up Now</a>
        </div>
    </div>

    <footer class="text-center py-4 border-top border-secondary">
        <div class="container">
            <p class="text-secondary mb-0 small">&copy; 2025 CampusConnect. All rights reserved. | Connect, Share, Grow</p>
        </div>
    </footer>

    <!-- Three.js (unchanged 3D models) -->
    <script type="importmap">
        {
            "imports": {
                "three": "https://unpkg.com/three@0.128.0/build/three.module.js"
            }
        }
    </script>
    <script type="module">
        import * as THREE from 'three';

        const container = document.getElementById('canvas-container');
        const scene = new THREE.Scene();
        scene.background = null;
        scene.fog = new THREE.FogExp2(0x0a0a0a, 0.008);

        const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 100);
        camera.position.set(0, 2.2, 6);
        camera.lookAt(0, 1.5, 0);

        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(container.clientWidth, container.clientHeight);
        renderer.setClearColor(0x000000, 0);
        container.appendChild(renderer.domElement);

        // Lighting
        const ambientLight = new THREE.AmbientLight(0x404060);
        scene.add(ambientLight);
        const mainLight = new THREE.DirectionalLight(0xffffff, 1);
        mainLight.position.set(3, 5, 2);
        scene.add(mainLight);
        const fillLight = new THREE.PointLight(0xffaa66, 0.5);
        fillLight.position.set(2, 2, 3);
        scene.add(fillLight);
        const rimLight = new THREE.PointLight(0x00e5ff, 0.4);
        rimLight.position.set(0, 2, -3);
        scene.add(rimLight);
        const bottomFill = new THREE.PointLight(0x88aaff, 0.3);
        bottomFill.position.set(0, -1, 1);
        scene.add(bottomFill);

        // Student group (same as original)
        const studentGroup = new THREE.Group();
        studentGroup.position.set(-1.5, -0.2, 0);
        const bodyGeo = new THREE.BoxGeometry(0.7, 0.9, 0.5);
        const bodyMat = new THREE.MeshStandardMaterial({ color: 0x3a86ff, roughness: 0.3 });
        const body = new THREE.Mesh(bodyGeo, bodyMat);
        body.position.y = 0;
        studentGroup.add(body);
        const headGeo = new THREE.SphereGeometry(0.5, 32, 32);
        const headMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
        const head = new THREE.Mesh(headGeo, headMat);
        head.position.y = 0.75;
        studentGroup.add(head);
        const eyeWhite = new THREE.MeshStandardMaterial({ color: 0xffffff });
        const leftEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeWhite);
        leftEye.position.set(-0.18, 0.9, 0.52);
        studentGroup.add(leftEye);
        const rightEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeWhite);
        rightEye.position.set(0.18, 0.9, 0.52);
        studentGroup.add(rightEye);
        const pupilMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
        const leftPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), pupilMat);
        leftPupil.position.set(-0.18, 0.88, 0.6);
        studentGroup.add(leftPupil);
        const rightPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), pupilMat);
        rightPupil.position.set(0.18, 0.88, 0.6);
        studentGroup.add(rightPupil);
        const smileMat = new THREE.MeshStandardMaterial({ color: 0xaa6644 });
        const smile = new THREE.Mesh(new THREE.TorusGeometry(0.18, 0.05, 16, 32, Math.PI), smileMat);
        smile.rotation.x = 0.2;
        smile.position.set(0, 0.72, 0.58);
        studentGroup.add(smile);
        const capBase = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.08, 0.7), new THREE.MeshStandardMaterial({ color: 0x222222 }));
        capBase.position.set(0, 1.02, 0);
        studentGroup.add(capBase);
        const capTop = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.08, 0.45), new THREE.MeshStandardMaterial({ color: 0x222222 }));
        capTop.position.set(0, 1.09, 0);
        studentGroup.add(capTop);
        const tassel = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.03, 0.25, 6), new THREE.MeshStandardMaterial({ color: 0xffaa44 }));
        tassel.position.set(0.25, 1.07, 0.2);
        tassel.rotation.z = 0.5;
        studentGroup.add(tassel);
        const backpack = new THREE.Mesh(new THREE.BoxGeometry(0.6, 0.7, 0.3), new THREE.MeshStandardMaterial({ color: 0x8B5A2B }));
        backpack.position.set(0, 0.2, -0.45);
        studentGroup.add(backpack);
        const armMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
        const leftArm = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, 0.65, 8), armMat);
        leftArm.position.set(-0.55, 0.75, 0);
        leftArm.rotation.z = 0.4;
        studentGroup.add(leftArm);
        const rightArm = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, 0.65, 8), armMat);
        rightArm.position.set(0.55, 0.75, 0);
        rightArm.rotation.z = -0.4;
        studentGroup.add(rightArm);
        const legMat = new THREE.MeshStandardMaterial({ color: 0x2c5f8a });
        const leftLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.13, 0.13, 0.65, 8), legMat);
        leftLeg.position.set(-0.22, -0.4, 0);
        studentGroup.add(leftLeg);
        const rightLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.13, 0.13, 0.65, 8), legMat);
        rightLeg.position.set(0.22, -0.4, 0);
        studentGroup.add(rightLeg);
        scene.add(studentGroup);

        // Teacher group
        const teacherGroup = new THREE.Group();
        teacherGroup.position.set(1.5, -0.2, 0);
        const tBodyGeo = new THREE.BoxGeometry(0.75, 0.95, 0.55);
        const tBodyMat = new THREE.MeshStandardMaterial({ color: 0x4a4e69, metalness: 0.2 });
        const tBody = new THREE.Mesh(tBodyGeo, tBodyMat);
        tBody.position.y = 0;
        teacherGroup.add(tBody);
        const tie = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.4, 0.05), new THREE.MeshStandardMaterial({ color: 0xcc3333 }));
        tie.position.set(0, 0.15, 0.3);
        teacherGroup.add(tie);
        const tHeadGeo = new THREE.SphereGeometry(0.52, 32, 32);
        const tHeadMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
        const tHead = new THREE.Mesh(tHeadGeo, tHeadMat);
        tHead.position.y = 0.78;
        teacherGroup.add(tHead);
        const glassMat = new THREE.MeshStandardMaterial({ color: 0xccccdd, metalness: 0.7 });
        const leftLens = new THREE.Mesh(new THREE.TorusGeometry(0.14, 0.04, 16, 32), glassMat);
        leftLens.position.set(-0.22, 0.92, 0.55);
        teacherGroup.add(leftLens);
        const rightLens = new THREE.Mesh(new THREE.TorusGeometry(0.14, 0.04, 16, 32), glassMat);
        rightLens.position.set(0.22, 0.92, 0.55);
        teacherGroup.add(rightLens);
        const bridge = new THREE.Mesh(new THREE.BoxGeometry(0.2, 0.05, 0.05), glassMat);
        bridge.position.set(0, 0.92, 0.6);
        teacherGroup.add(bridge);
        const tEyeMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
        const tLeftEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), tEyeMat);
        tLeftEye.position.set(-0.22, 0.94, 0.52);
        teacherGroup.add(tLeftEye);
        const tRightEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), tEyeMat);
        tRightEye.position.set(0.22, 0.94, 0.52);
        teacherGroup.add(tRightEye);
        const tPupilMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
        const tLeftPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), tPupilMat);
        tLeftPupil.position.set(-0.22, 0.92, 0.61);
        teacherGroup.add(tLeftPupil);
        const tRightPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), tPupilMat);
        tRightPupil.position.set(0.22, 0.92, 0.61);
        teacherGroup.add(tRightPupil);
        const mustache = new THREE.Mesh(new THREE.TorusGeometry(0.18, 0.05, 8, 24, Math.PI), new THREE.MeshStandardMaterial({ color: 0x8B5A2B }));
        mustache.rotation.x = 0.2;
        mustache.position.set(0, 0.8, 0.58);
        teacherGroup.add(mustache);
        const pointer = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, 0.7, 8), new THREE.MeshStandardMaterial({ color: 0xdd8866 }));
        pointer.position.set(0.65, 0.9, 0.3);
        pointer.rotation.z = -0.5;
        pointer.rotation.x = 0.3;
        teacherGroup.add(pointer);
        const tArmMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
        const tLeftArm = new THREE.Mesh(new THREE.CylinderGeometry(0.11, 0.11, 0.7, 8), tArmMat);
        tLeftArm.position.set(-0.6, 0.8, 0);
        tLeftArm.rotation.z = 0.3;
        teacherGroup.add(tLeftArm);
        const tRightArm = new THREE.Mesh(new THREE.CylinderGeometry(0.11, 0.11, 0.7, 8), tArmMat);
        tRightArm.position.set(0.6, 0.8, 0);
        tRightArm.rotation.z = -0.5;
        teacherGroup.add(tRightArm);
        const tLegMat = new THREE.MeshStandardMaterial({ color: 0x3a3a4a });
        const tLeftLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.14, 0.14, 0.7, 8), tLegMat);
        tLeftLeg.position.set(-0.24, -0.4, 0);
        teacherGroup.add(tLeftLeg);
        const tRightLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.14, 0.14, 0.7, 8), tLegMat);
        tRightLeg.position.set(0.24, -0.4, 0);
        teacherGroup.add(tRightLeg);
        scene.add(teacherGroup);

        // Particles
        const particleCount = 400;
        const particlesGeometry = new THREE.BufferGeometry();
        const particlePositions = new Float32Array(particleCount * 3);
        for (let i = 0; i < particleCount; i++) {
            particlePositions[i*3] = (Math.random() - 0.5) * 35;
            particlePositions[i*3+1] = (Math.random() - 0.5) * 18;
            particlePositions[i*3+2] = (Math.random() - 0.5) * 25 - 12;
        }
        particlesGeometry.setAttribute('position', new THREE.BufferAttribute(particlePositions, 3));
        const particles = new THREE.Points(particlesGeometry, new THREE.PointsMaterial({ color: 0x00e5ff, size: 0.07, transparent: true, opacity: 0.5 }));
        scene.add(particles);

        let time = 0;
        function animate() {
            requestAnimationFrame(animate);
            time += 0.012;

            studentGroup.position.y = -0.2 + Math.sin(time) * 0.04;
            teacherGroup.position.y = -0.2 + Math.sin(time + 1.5) * 0.04;
            studentGroup.rotation.y = Math.sin(time * 0.6) * 0.15;
            teacherGroup.rotation.y = Math.sin(time * 0.6 + 2) * 0.12;
            leftArm.rotation.z = 0.4 + Math.sin(time * 2) * 0.25;
            rightArm.rotation.z = -0.4 - Math.sin(time * 2) * 0.25;
            tRightArm.rotation.z = -0.5 + Math.sin(time * 1.8) * 0.2;
            particles.rotation.y = time * 0.03;
            particles.rotation.x = Math.sin(time * 0.2) * 0.1;
            camera.position.x = Math.sin(time * 0.2) * 0.08;
            camera.lookAt(0, 1.4, 0);

            renderer.render(scene, camera);
        }
        animate();

        window.addEventListener('resize', () => {
            const width = container.clientWidth;
            const height = container.clientHeight;
            camera.aspect = width / height;
            camera.updateProjectionMatrix();
            renderer.setSize(width, height);
        });
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>