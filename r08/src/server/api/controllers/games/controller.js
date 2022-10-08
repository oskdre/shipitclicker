import RedisService from '../../services/redis.service';
import l from '../../../common/logger';
import { nanoid } from 'nanoid';

export class Controller {
  async getGame(req, res) {
    const id = `${req.params.id}`;
    try {
      var redis = await RedisService.get(id);
      l.debug({ msg: 'Redis GET wykonane', key: id, value: redis });
      return res.json({
        id: req.params.id,
        started_on: redis,
      });
    } catch (err) {
      l.warn({ msg: 'Redis GET errored', key: req.params.id, error: err });
      return res.status(404);
    }
  }

  async createGame(req, res) {
    try {
      const id = nanoid();
      const started_on = new Date().getTime();
      var redis = await RedisService.set(id, started_on);
      l.debug({ msg: 'Redis SET wykonane', key: id, value: redis });
      return res.status(201).json({
        id: id,
        started_on: started_on,
      });
    } catch (err) {
      l.error({ msg: 'Błąd Redis SET', error: err });
      return res.status(500);
    }
  }

  async getGameItem(req, res) {
    try {
      const key = `${req.params.id}/${req.params.element}`;
      var redis = await RedisService.get(key);
      l.debug({ msg: 'Redis GET wykonane', key: key, value: redis });
      return res.json({
        id: req.params.id,
        element: req.params.element,
        value: redis,
      });
    } catch (err) {
      l.error({
        msg: 'Błąd Redis GET',
        id: req.params.id,
        element: req.params.element,
        error: err,
      });
      return res.status(404);
    }
  }

  async setGameItem(req, res) {
    try {
      const key = `${req.body.id}/${req.body.element}`;
      var redis = await RedisService.set(key, req.body.value);
      l.debug({ msg: 'Redis SET wykonane', key: key, value: redis });
      return res.status(201).json({
        id: req.body.id,
        element: req.body.element,
        value: req.body.value,
      });
    } catch (err) {
      l.error({
        msg: 'Błąd Redis SET',
        key: req.body.id,
        error: err,
      });
      return res.status(500);
    }
  }

  async incrementGameItem(req, res) {
    try {
      const key = `${req.body.id}/${req.body.element}`;
      var redis = await RedisService.incrby(key, req.body.value);
      l.debug({ msg: 'Redis INCRBY wykonane', key: key, value: redis });
      return res.json({
        id: req.params.id,
        element: req.params.element,
        value: redis,
      });
    } catch (err) {
      l.warn({
        msg: 'Błąd Redis INCRBY',
        key: req.body.id,
        element: req.body.element,
        error: err,
      });
      return res.status(404);
    }
  }
}
export default new Controller();
