import Request from './Request';

export default (token) => {
  return new Request('/orders', token).get();
};
