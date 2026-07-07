// 運営用APIの初期座席データ。60席を用意し、AIエージェントたちが奪い合う母数とする。
// 一部は最初から予約済みにしておき、予約済み/空席の両方がindexに表示されることを
// 起動直後から確認できるようにする。
export function createSeedSeats() {
  const sections = [
    { section: "front", rows: ["A", "B", "C"], base: 6000 },
    { section: "middle", rows: ["D", "E", "F", "G"], base: 4000 },
    { section: "back", rows: ["H", "I", "J"], base: 2500 },
  ];
  const positions = ["aisle", "window", "center"];
  const tagPool = {
    front: ["view", "power"],
    middle: ["power", "spacious"],
    back: ["quiet"],
  };

  const seats = [];
  for (const { section, rows, base } of sections) {
    rows.forEach((row, rowIndex) => {
      for (let seatIndex = 1; seatIndex <= 6; seatIndex += 1) {
        const position = positions[seatIndex % positions.length];
        const tags = [...tagPool[section]];
        if (position === "aisle") tags.push("aisle-easy");
        if (position === "window" && section !== "back") tags.push("view");
        if (section === "back" || position === "window") tags.push("quiet");

        seats.push({
          id: `${row}-${seatIndex}`,
          row,
          section,
          position,
          price: base - rowIndex * 300,
          tags: [...new Set(tags)],
          status: "available",
          reservedBy: null,
        });
      }
    });
  }

  for (const seatId of ["A-1", "A-2", "D-1"]) {
    const seat = seats.find((s) => s.id === seatId);
    if (seat) {
      seat.status = "reserved";
      seat.reservedBy = "既存参加者";
    }
  }

  return seats;
}
