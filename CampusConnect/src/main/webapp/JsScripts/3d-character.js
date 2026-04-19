// JsScripts/3d-character.js
// Shared 3D character for all pages

import * as THREE from 'three';

export function init3DCharacter(containerId = 'char-canvas') {
    // Create container if not exists
    let container = document.getElementById(containerId);
    if (!container) {
        container = document.createElement('div');
        container.id = containerId;
        container.style.position = 'fixed';
        container.style.bottom = '20px';
        container.style.right = '20px';
        container.style.width = '160px';
        container.style.height = '160px';
        container.style.zIndex = '999';
        container.style.pointerEvents = 'none';
        document.body.appendChild(container);
    }

    // Scene setup
    const scene = new THREE.Scene();
    scene.background = null;

    const camera = new THREE.PerspectiveCamera(45, 1, 0.1, 100);
    camera.position.set(0, 1.5, 3);
    camera.lookAt(0, 1, 0);

    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setClearColor(0x000000, 0);
    container.appendChild(renderer.domElement);

    // Lighting
    const ambient = new THREE.AmbientLight(0x404060);
    scene.add(ambient);
    const mainLight = new THREE.DirectionalLight(0xffffff, 1);
    mainLight.position.set(2, 3, 2);
    scene.add(mainLight);
    const fillLight = new THREE.PointLight(0x2266ff, 0.5);
    fillLight.position.set(-1, 2, 2);
    scene.add(fillLight);
    const backLight = new THREE.PointLight(0x00e5ff, 0.3);
    backLight.position.set(0, 1.5, -2);
    scene.add(backLight);

    // Character group
    const character = new THREE.Group();

    // Body (blue shirt)
    const bodyGeo = new THREE.BoxGeometry(0.65, 0.85, 0.55);
    const bodyMat = new THREE.MeshStandardMaterial({ color: 0x00aaff, emissive: 0x004466 });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = 0;
    character.add(body);

    // Head
    const headGeo = new THREE.SphereGeometry(0.48, 32, 32);
    const headMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
    const head = new THREE.Mesh(headGeo, headMat);
    head.position.y = 0.72;
    character.add(head);

    // Eyes
    const eyeMat = new THREE.MeshStandardMaterial({ color: 0xffffff });
    const leftEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeMat);
    leftEye.position.set(-0.18, 0.88, 0.48);
    character.add(leftEye);
    const rightEye = new THREE.Mesh(new THREE.SphereGeometry(0.1, 24, 24), eyeMat);
    rightEye.position.set(0.18, 0.88, 0.48);
    character.add(rightEye);

    // Pupils
    const pupilMat = new THREE.MeshStandardMaterial({ color: 0x000000 });
    const leftPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), pupilMat);
    leftPupil.position.set(-0.18, 0.86, 0.57);
    character.add(leftPupil);
    const rightPupil = new THREE.Mesh(new THREE.SphereGeometry(0.06, 24, 24), pupilMat);
    rightPupil.position.set(0.18, 0.86, 0.57);
    character.add(rightPupil);

    // Smile
    const smileMat = new THREE.MeshStandardMaterial({ color: 0xaa6644 });
    const smile = new THREE.Mesh(new THREE.TorusGeometry(0.16, 0.04, 16, 32, Math.PI), smileMat);
    smile.rotation.x = 0.2;
    smile.position.set(0, 0.71, 0.57);
    character.add(smile);

    // Hair (brown)
    const hairMat = new THREE.MeshStandardMaterial({ color: 0x8B5A2B });
    const hair = new THREE.Mesh(new THREE.CylinderGeometry(0.52, 0.55, 0.16, 8), hairMat);
    hair.position.y = 0.98;
    character.add(hair);

    // Arms (cylinders)
    const armMat = new THREE.MeshStandardMaterial({ color: 0xffccaa });
    const leftArm = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, 0.6, 8), armMat);
    leftArm.position.set(-0.5, 0.75, 0);
    leftArm.rotation.z = 0.4;
    character.add(leftArm);
    const rightArm = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.1, 0.6, 8), armMat);
    rightArm.position.set(0.5, 0.75, 0);
    rightArm.rotation.z = -0.4;
    character.add(rightArm);

    // Legs
    const legMat = new THREE.MeshStandardMaterial({ color: 0x2266aa });
    const leftLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.65, 8), legMat);
    leftLeg.position.set(-0.25, -0.45, 0);
    character.add(leftLeg);
    const rightLeg = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.65, 8), legMat);
    rightLeg.position.set(0.25, -0.45, 0);
    character.add(rightLeg);

    // Backpack
    const backpack = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.65, 0.25), new THREE.MeshStandardMaterial({ color: 0xaa8866 }));
    backpack.position.set(0, 0.15, -0.45);
    character.add(backpack);

    scene.add(character);

    // Floating particles (stars)
    const particleCount = 150;
    const particlesGeo = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount; i++) {
        positions[i*3] = (Math.random() - 0.5) * 5;
        positions[i*3+1] = (Math.random() - 0.5) * 4 + 1;
        positions[i*3+2] = (Math.random() - 0.5) * 4 - 2;
    }
    particlesGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const particlesMat = new THREE.PointsMaterial({ color: 0x00e5ff, size: 0.04, transparent: true, opacity: 0.5 });
    const particles = new THREE.Points(particlesGeo, particlesMat);
    scene.add(particles);

    let time = 0;
    function animate() {
        requestAnimationFrame(animate);
        time += 0.02;

        // Floating and gentle rotation
        character.position.y = Math.sin(time) * 0.03;
        character.rotation.y = Math.sin(time * 0.7) * 0.2;
        
        // Arm waving
        leftArm.rotation.z = 0.4 + Math.sin(time * 2) * 0.3;
        rightArm.rotation.z = -0.4 - Math.sin(time * 2) * 0.3;

        // Rotate particles
        particles.rotation.y = time * 0.1;
        particles.rotation.x = Math.sin(time * 0.3) * 0.1;

        renderer.render(scene, camera);
    }
    animate();

    // Handle resize
    const resizeObserver = new ResizeObserver(() => {
        const w = container.clientWidth;
        const h = container.clientHeight;
        renderer.setSize(w, h);
        camera.aspect = w / h;
        camera.updateProjectionMatrix();
    });
    resizeObserver.observe(container);
}