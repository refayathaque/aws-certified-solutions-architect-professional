import express from "express";
import listBuckets from "./listBuckets.js";
import listObjects from "./listObjects.js";
import createBucket from "./createBucket.js";
import deleteBucket from "./deleteBucket.js";
import deleteObject from "./deleteObject.js";
import updateObject from "./updateObject.js";

const HOST = "0.0.0.0";
const PORT = process.env.PORT || 8080;

const app = express();

app.get("/everything", (req, res) => {
  res.status(200).json("everything");
});

app.get("/buckets", async (req, res) => {
  const buckets = await listBuckets();
  res.status(200).json(buckets);
});
// https://zellwk.com/blog/async-await-express/

app.get("/objects/:bucket", async (req, res) => {
  const { bucket } = req.params;
  const objects = await listObjects(bucket);
  res.status(200).json(objects);
});

app.post("/buckets/:name", async (req, res) => {
  const { name } = req.params;
  const response = await createBucket(name);
  res.status(200).json(response);
  // will error if trying to create bucket with name of existing bucket
});

app.delete("/buckets/:name", async (req, res) => {
  const { name } = req.params;
  const response = await deleteBucket(name);
  res.status(200).json(response);
  // will error if trying to delete bucket with name that doesn't exist
});

app.delete("/objects/:bucket/:name", async (req, res) => {
  const { bucket } = req.params;
  const { name } = req.params;
  const response = await deleteObject(bucket, name);
  res.status(200).json(response);
  // will error if trying to delete bucket with name that doesn't exist
});

app.put("/objects/:bucket/:name/:newName", async (req, res) => {
  const { bucket } = req.params;
  const { name } = req.params;
  const { newName } = req.params;
  const response = await updateObject(bucket, name, newName);
  res.status(200).json(response);
  // will error if trying to delete bucket with name that doesn't exist
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

// The res object represents the HTTP response that an Express app sends when it gets an HTTP request.
// https://expressjs.com/en/4x/api.html#res
// The req object represents the HTTP request and has properties for the request query string, parameters, body, HTTP headers, and so on.
// https://expressjs.com/en/4x/api.html#req

// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#successful_responses