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
})();
