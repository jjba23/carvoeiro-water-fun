/* Carvoeiro Water Fun — maritime motion
 *
 * SPDX-License-Identifier: MIT
 * Copyright © Josep Bigorra <jjbigorra@gmail.com>
 *
 * Four small behaviours, no dependencies: sections arrive as they are scrolled
 * to, glass panels lean towards the pointer, photographs drift inside their
 * frames, and the tide line at the top fills with the part of the page already
 * read.  All of it is opt-out — with
 * prefers-reduced-motion the page is complete on its own and only the tide line
 * keeps working, because it reports the reading position rather than decorates.
 */

// @ts-check
"use strict";

(function () {
    /** @type {HTMLElement} */
    const root = document.documentElement;
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
    const finePointer = window.matchMedia("(hover: hover) and (pointer: fine)");

    /**
     * Reveal each section once, staggering panels that enter together.
     */
    const reveal = () => {
        /** @type {HTMLElement[]} */
        const items = Array.from(document.querySelectorAll("[data-reveal]"));
        if (!items.length) return;

        if (!("IntersectionObserver" in window) || reducedMotion.matches) {
            items.forEach((item) => item.classList.add("is-visible"));
            return;
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (!entry.isIntersecting) return;
                const item = /** @type {HTMLElement} */ (entry.target);
                const parent = item.parentElement;
                const siblings = parent
                    ? Array.from(parent.children).filter((node) => node.hasAttribute("data-reveal"))
                    : [item];
                const order = Math.max(0, siblings.indexOf(item));
                item.style.setProperty("--reveal-delay", Math.min(order, 5) * 90 + "ms");
                item.classList.add("is-visible");
                observer.unobserve(item);
            });
        }, { rootMargin: "0px 0px -10% 0px", threshold: 0.12 });

        items.forEach((item) => observer.observe(item));
    };

    /**
     * Lean each [data-tilt] panel a couple of degrees towards the pointer.
     * The angles are handed to the stylesheet, so motion stays cancellable in
     * one place and a coarse pointer never pays for it.
     */
    const tilt = () => {
        /** @type {HTMLElement[]} */
        const panels = Array.from(document.querySelectorAll("[data-tilt]"));
        if (!panels.length || !finePointer.matches || reducedMotion.matches) return;

        panels.forEach((panel) => {
            let frame = 0;

            const onMove = (event) => {
                const box = panel.getBoundingClientRect();
                const x = (event.clientX - box.left) / box.width - 0.5;
                const y = (event.clientY - box.top) / box.height - 0.5;
                cancelAnimationFrame(frame);
                frame = requestAnimationFrame(() => {
                    panel.style.setProperty("--tilt-y", (x * 4).toFixed(2) + "deg");
                    panel.style.setProperty("--tilt-x", (-y * 4).toFixed(2) + "deg");
                });
            };

            panel.addEventListener("pointerenter", () => panel.classList.add("is-tilting"));
            panel.addEventListener("pointermove", onMove);
            panel.addEventListener("pointerleave", () => {
                cancelAnimationFrame(frame);
                panel.classList.remove("is-tilting");
                panel.style.removeProperty("--tilt-x");
                panel.style.removeProperty("--tilt-y");
            });
        });
    };

    /**
     * Drift each [data-parallax] layer inside its frame as the page is read.
     * The attribute holds how many pixels the layer may travel; the offset is
     * handed to the stylesheet, which owns the rest of the movement.
     */
    const parallax = () => {
        /** @type {HTMLElement[]} */
        const layers = Array.from(document.querySelectorAll("[data-parallax]"));
        if (!layers.length || reducedMotion.matches) return;

        /** @type {Set<Element>} */
        const visible = new Set();

        if ("IntersectionObserver" in window) {
            const watcher = new IntersectionObserver((entries) => {
                entries.forEach((entry) => {
                    if (entry.isIntersecting) visible.add(entry.target);
                    else visible.delete(entry.target);
                });
            }, { rootMargin: "120px" });
            layers.forEach((layer) => watcher.observe(layer));
        } else {
            layers.forEach((layer) => visible.add(layer));
        }

        let queued = false;

        const paint = () => {
            queued = false;
            const middle = window.innerHeight / 2;
            visible.forEach((layer) => {
                if (!(layer instanceof HTMLElement)) return;
                const box = layer.getBoundingClientRect();
                const depth = Number(layer.dataset.parallax) || 24;
                const offset = ((box.top + box.height / 2 - middle)
                    / window.innerHeight) * depth;
                layer.style.setProperty("--parallax", offset.toFixed(2) + "px");
            });
        };

        const schedule = () => {
            if (queued) return;
            queued = true;
            requestAnimationFrame(paint);
        };

        window.addEventListener("scroll", schedule, { passive: true });
        window.addEventListener("resize", schedule);
        paint();
    };

    /**
     * Fill the tide line with the fraction of the page that has been read.
     */
    const tideLine = () => {
        const fill = document.querySelector(".tide-line__fill");
        if (!(fill instanceof HTMLElement)) return;

        let queued = false;

        const paint = () => {
            const scrollable = root.scrollHeight - window.innerHeight;
            const progress = scrollable > 0
                ? Math.min(1, Math.max(0, window.scrollY / scrollable))
                : 0;
            fill.style.setProperty("--progress", progress.toFixed(4));
            queued = false;
        };

        const schedule = () => {
            if (queued) return;
            queued = true;
            requestAnimationFrame(paint);
        };

        window.addEventListener("scroll", schedule, { passive: true });
        window.addEventListener("resize", schedule);
        paint();
    };


    /**
     * Turn the gallery into something you can leave running: it advances on
     * its own, stops as soon as a reader shows interest, and can be dragged,
     * dotted or arrowed through.  Everything pauses when the page is hidden or
     * the strip is off screen, and nothing starts under reduced motion.
     */
    const carousel = () => {
        /** @type {HTMLElement[]} */
        const shells = Array.from(document.querySelectorAll("[data-carousel]"));
        if (!shells.length) return;

        shells.forEach((shell) => {
            const list = shell.querySelector(".carousel-list");
            if (!(list instanceof HTMLElement)) return;

            /** @type {HTMLElement[]} */
            const slides = Array.from(list.children).filter((node) => node instanceof HTMLElement);
            /** @type {HTMLElement[]} */
            const dots = Array.from(shell.querySelectorAll("[data-carousel-dot]"));
            if (slides.length < 2) return;

            list.setAttribute("tabindex", "0");
            list.setAttribute("aria-roledescription", "carousel");

            let active = 0;
            let timer = 0;
            let paused = false;
            let dragging = false;
            let visible = true;

            const gap = () => {
                const style = getComputedStyle(list);
                return parseFloat(style.columnGap || style.gap || "0") || 0;
            };

            const step = () => slides[0].getBoundingClientRect().width + gap();

            const mark = (index) => {
                active = Math.max(0, Math.min(slides.length - 1, index));
                dots.forEach((dot, i) => {
                    const on = i === active;
                    dot.classList.toggle("is-active", on);
                    dot.setAttribute("aria-pressed", on ? "true" : "false");
                });
            };

            const goTo = (index, smooth) => {
                const target = Math.max(0, Math.min(slides.length - 1, index));
                mark(target);
                list.scrollTo({
                    left: slides[target].offsetLeft - slides[0].offsetLeft,
                    behavior: smooth && !reducedMotion.matches ? "smooth" : "auto"
                });
            };

            const advance = () => {
                if (reducedMotion.matches || document.hidden || !visible) return;
                goTo(active + 1 >= slides.length ? 0 : active + 1, true);
            };

            const restart = () => {
                window.clearInterval(timer);
                if (paused || reducedMotion.matches) return;
                timer = window.setInterval(advance, 6000);
            };

            const stop = () => {
                window.clearInterval(timer);
                timer = 0;
            };

            const hold = () => {
                paused = true;
                stop();
            };

            const release = () => {
                paused = false;
                restart();
            };

            dots.forEach((dot, index) => {
                dot.addEventListener("click", () => {
                    goTo(index, true);
                    release();
                });
            });

            list.addEventListener("scroll", () => {
                const index = Math.round(list.scrollLeft / Math.max(1, step()));
                if (index !== active) mark(index);
            }, { passive: true });

            list.addEventListener("keydown", (event) => {
                if (event.key === "ArrowRight") {
                    event.preventDefault();
                    goTo(active + 1, true);
                    release();
                } else if (event.key === "ArrowLeft") {
                    event.preventDefault();
                    goTo(active - 1, true);
                    release();
                } else if (event.key === "Home") {
                    event.preventDefault();
                    goTo(0, true);
                    release();
                } else if (event.key === "End") {
                    event.preventDefault();
                    goTo(slides.length - 1, true);
                    release();
                }
            });

            list.addEventListener("pointerenter", (event) => {
                if (event.pointerType === "mouse") hold();
            });
            list.addEventListener("pointerleave", () => {
                if (!dragging) release();
            });
            list.addEventListener("focusin", hold);
            list.addEventListener("focusout", release);
            list.addEventListener("dragstart", (event) => event.preventDefault());

            let startX = 0;
            let startLeft = 0;
            let moved = false;
            let lastX = 0;
            let lastTime = 0;
            let velocity = 0;

            list.addEventListener("pointerdown", (event) => {
                if (event.pointerType !== "mouse" || event.button !== 0) return;
                dragging = true;
                moved = false;
                startX = event.clientX;
                startLeft = list.scrollLeft;
                lastX = event.clientX;
                lastTime = performance.now();
                velocity = 0;
                list.classList.add("is-dragging");
                list.setPointerCapture(event.pointerId);
                hold();
            });

            list.addEventListener("pointermove", (event) => {
                if (!dragging) return;
                const dx = event.clientX - startX;
                if (Math.abs(dx) > 4) moved = true;
                list.scrollLeft = startLeft - dx;
                const now = performance.now();
                const dt = now - lastTime;
                if (dt > 0) velocity = (event.clientX - lastX) / dt;
                lastX = event.clientX;
                lastTime = now;
            });

            const endDrag = (event) => {
                if (!dragging) return;
                dragging = false;
                list.classList.remove("is-dragging");
                try {
                    list.releasePointerCapture(event.pointerId);
                } catch (error) {
                    /* the pointer may already be gone */
                }
                if (moved) {
                    list.scrollTo({
                        left: list.scrollLeft - velocity * 240,
                        behavior: reducedMotion.matches ? "auto" : "smooth"
                    });
                    window.setTimeout(() => {
                        goTo(Math.round(list.scrollLeft / Math.max(1, step())), true);
                    }, 260);
                }
                release();
            };

            list.addEventListener("pointerup", endDrag);
            list.addEventListener("pointercancel", endDrag);

            if ("IntersectionObserver" in window) {
                const watcher = new IntersectionObserver((entries) => {
                    entries.forEach((entry) => {
                        visible = entry.isIntersecting;
                        if (visible) restart();
                        else stop();
                    });
                }, { rootMargin: "80px" });
                watcher.observe(shell);
            }

            document.addEventListener("visibilitychange", () => {
                if (document.hidden) stop();
                else restart();
            });

            mark(0);
            restart();
        });
    };

    /**
     * A panorama you can pull by its edge: the photograph slides under the
     * frame, drifts on its own while nobody is holding it, and answers the
     * keyboard.  A second scene is preloaded only after the first is in view.
     */
    const panorama = () => {
        /** @type {HTMLElement[]} */
        const stages = Array.from(document.querySelectorAll("[data-panorama]"));
        if (!stages.length) return;

        stages.forEach((stage) => {
            const surface = stage.querySelector(".panorama-surface");
            const hint = stage.querySelector(".panorama-hint");
            const thumb = stage.querySelector(".panorama-rail__thumb");
            const panel = stage.closest(".panorama");
            if (!(surface instanceof HTMLElement) || !panel) return;

            /** @type {HTMLElement[]} */
            const tabs = Array.from(panel.querySelectorAll("[data-pano-tab]"));
            let loaded = false;
            let x = 0;
            let max = 0;
            let hovering = false;
            let dragging = false;
            let startX = 0;
            let startPos = 0;
            let visible = false;
            let frame = 0;
            let last = 0;
            let direction = 1;
            let swap = 0;

            const ratio = () => Number(stage.getAttribute("data-pano-ratio")) || 2;
            const source = () => stage.getAttribute("data-pano-src") || "";

            const load = () => {
                if (loaded) return;
                const url = source();
                if (!url) return;
                surface.style.backgroundImage = "url(" + JSON.stringify(url) + ")";
                loaded = true;
            };

            const measure = () => {
                const style = getComputedStyle(surface);
                const size = (style.backgroundSize || "auto 165%").split(" ");
                const factor = size[1] && size[1].endsWith("%")
                    ? parseFloat(size[1]) / 100
                    : 1.65;
                const height = stage.clientHeight;
                const width = height * factor * ratio();
                max = Math.max(0, width - stage.clientWidth);
                if (x > max) x = max;
                if (x < 0) x = 0;
            };

            const paint = () => {
                surface.style.backgroundPosition = (-x).toFixed(1) + "px center";
                if (thumb instanceof HTMLElement) {
                    const width = max > 0
                        ? Math.max(12, (stage.clientWidth / (stage.clientWidth + max)) * 100)
                        : 100;
                    const left = max > 0 ? (x / max) * (100 - width) : 0;
                    thumb.style.width = width.toFixed(2) + "%";
                    thumb.style.left = left.toFixed(2) + "%";
                }
            };

            const drift = (time) => {
                const delta = last ? Math.min(64, time - last) : 0;
                last = time;
                const running = visible && !dragging && !hovering && !reducedMotion.matches;
                if (running && max > 0) {
                    x += direction * delta * 0.012;
                    if (x >= max) {
                        x = max;
                        direction = -1;
                    } else if (x <= 0) {
                        x = 0;
                        direction = 1;
                    }
                    paint();
                }
                frame = requestAnimationFrame(drift);
            };

            const select = (tab) => {
                if (tab.classList.contains("is-active")) return;
                const url = tab.getAttribute("data-pano-src");
                const value = tab.getAttribute("data-pano-ratio");
                const label = tab.getAttribute("data-pano-label");
                if (!url) return;
                stage.setAttribute("data-pano-src", url);
                if (value) stage.setAttribute("data-pano-ratio", value);
                if (label) stage.setAttribute("aria-label", "Panorama: " + label);
                tabs.forEach((other) => {
                    const on = other === tab;
                    other.classList.toggle("is-active", on);
                    other.setAttribute("aria-pressed", on ? "true" : "false");
                });
                loaded = false;
                x = 0;
                last = 0;
                if (reducedMotion.matches) {
                    load();
                    measure();
                    paint();
                    return;
                }
                /* Dip the old scene, bring the new one up: a cut would break
                   the illusion of turning your head. */
                window.clearTimeout(swap);
                surface.classList.add("is-swapping");
                swap = window.setTimeout(() => {
                    loaded = false;
                    load();
                    measure();
                    paint();
                    surface.classList.remove("is-swapping");
                }, 170);
            };

            tabs.forEach((tab) => {
                tab.addEventListener("click", () => select(tab));
            });

            stage.addEventListener("pointerenter", (event) => {
                if (event.pointerType === "mouse") hovering = true;
            });
            stage.addEventListener("pointerleave", () => {
                hovering = false;
            });

            stage.addEventListener("pointerdown", (event) => {
                dragging = true;
                startX = event.clientX;
                startPos = x;
                last = 0;
                stage.classList.add("is-dragging", "is-used");
                stage.setPointerCapture(event.pointerId);
            });

            stage.addEventListener("pointermove", (event) => {
                if (!dragging) return;
                const dx = event.clientX - startX;
                x = Math.max(0, Math.min(max, startPos - dx * 1.15));
                paint();
            });

            const endPan = (event) => {
                if (!dragging) return;
                dragging = false;
                stage.classList.remove("is-dragging");
                try {
                    stage.releasePointerCapture(event.pointerId);
                } catch (error) {
                    /* the pointer may already be gone */
                }
                last = 0;
            };

            stage.addEventListener("pointerup", endPan);
            stage.addEventListener("pointercancel", endPan);

            stage.addEventListener("keydown", (event) => {
                const jump = 90;
                if (event.key === "ArrowRight") {
                    event.preventDefault();
                    x = Math.min(max, x + jump);
                } else if (event.key === "ArrowLeft") {
                    event.preventDefault();
                    x = Math.max(0, x - jump);
                } else if (event.key === "Home") {
                    event.preventDefault();
                    x = 0;
                } else if (event.key === "End") {
                    event.preventDefault();
                    x = max;
                } else {
                    return;
                }
                stage.classList.add("is-used");
                last = 0;
                paint();
            });

            window.addEventListener("resize", () => {
                measure();
                paint();
            });

            if ("IntersectionObserver" in window) {
                const watcher = new IntersectionObserver((entries) => {
                    entries.forEach((entry) => {
                        visible = entry.isIntersecting;
                        if (!visible) return;
                        load();
                        measure();
                        paint();
                        if ("requestIdleCallback" in window) {
                            requestIdleCallback(() => {
                                tabs.forEach((tab) => {
                                    const url = tab.getAttribute("data-pano-src");
                                    if (url && tab !== tabs[0]) {
                                        const image = new Image();
                                        image.src = url;
                                    }
                                });
                            }, { timeout: 4000 });
                        }
                        watcher.unobserve(stage);
                    });
                }, { rootMargin: "200px" });
                watcher.observe(stage);
            } else {
                load();
                measure();
            }

            if (hint) hint.setAttribute("aria-hidden", "true");
            frame = requestAnimationFrame(drift);
            void frame;
        });
    };

    /** Park every panel flat when the reader turns motion down mid-page. */
    reducedMotion.addEventListener("change", (event) => {
        if (!event.matches) return;
        document.querySelectorAll("[data-tilt]").forEach((panel) => {
            if (!(panel instanceof HTMLElement)) return;
            panel.classList.remove("is-tilting");
            panel.style.removeProperty("--tilt-x");
            panel.style.removeProperty("--tilt-y");
        });
        document.querySelectorAll("[data-parallax]").forEach((layer) => {
            if (!(layer instanceof HTMLElement)) return;
            layer.style.removeProperty("--parallax");
        });
    });

    reveal();
    tilt();
    parallax();
    tideLine();
    carousel();
    panorama();
})();
