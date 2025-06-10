// place files you want to import through the `$lib` alias in this folder.

export interface ReservationRequestType {
  toString: string;
  toTitle: string;
}

export const makeReservationRequestType = (s: string) => {
  switch (s) {
    case "boat-tour":
      return new BoatTourReservationRequest();
    case "sup":
      return new SUPReservationRequest();
  }
};
export class BoatTourReservationRequest implements ReservationRequestType {
  toString = "boat-tour";
  toTitle = "Boat Tour DOLPHIN";
}

export class SUPReservationRequest implements ReservationRequestType {
  toString = "sup";
  toTitle = "SUP (Stand Up Paddeling) Tour";
}
