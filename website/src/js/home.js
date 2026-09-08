export function initHome() {
  const scroller = document.querySelector("[data-action-scroller]");
  const next = document.querySelector("[data-action-next]");
  const board = document.querySelector(".action-board");
  if (!scroller || !next || !board) return;

  const syncOverflow = () => {
    const overflowing = scroller.scrollWidth > scroller.clientWidth + 8;
    board.classList.toggle("is-overflow", overflowing);
    next.hidden = !overflowing;
  };

  next.addEventListener("click", () => {
    const card = scroller.querySelector(".action-card");
    const delta = card ? card.getBoundingClientRect().width + 18 : 220;
    scroller.scrollBy({ left: delta, behavior: "smooth" });
  });

  syncOverflow();
  window.addEventListener("resize", syncOverflow, { passive: true });
  if (typeof ResizeObserver !== "undefined") {
    new ResizeObserver(syncOverflow).observe(scroller);
  }
}
