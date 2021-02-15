export interface ICustomer {
  itemId: string; // userId: same as Cognito's username
  aspect: 'CUSTOMER';
  indexSK: string; // createdAt
  email: string;

  fullName?: string | null;
}

export const newZeroCustomer = (): ICustomer => ({
  itemId: '',
  aspect: 'CUSTOMER',
  indexSK: new Date().toISOString(),
  email: '',

  fullName: '',
});
