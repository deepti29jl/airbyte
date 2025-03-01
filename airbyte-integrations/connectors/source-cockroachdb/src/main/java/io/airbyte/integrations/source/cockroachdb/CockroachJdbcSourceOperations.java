package io.airbyte.integrations.source.cockroachdb;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.airbyte.commons.json.Jsons;
import io.airbyte.db.jdbc.JdbcSourceOperations;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;

/**
 * Class is the responsible for special Cockroach DataTypes handling
 */
public class CockroachJdbcSourceOperations extends JdbcSourceOperations {

  @Override
  protected void putBoolean(ObjectNode node, String columnName, ResultSet resultSet, int index) throws SQLException {
    if ("bit".equalsIgnoreCase(resultSet.getMetaData().getColumnTypeName(index))) {
      node.put(columnName, resultSet.getByte(index));
    } else {
      node.put(columnName, resultSet.getBoolean(index));
    }
  }

  @Override
  protected void putDouble(final ObjectNode node, final String columnName, final ResultSet resultSet, final int index) throws SQLException {
    node.put(columnName, resultSet.getDouble(index));
  }

  @Override
  protected void putNumber(final ObjectNode node, final String columnName, final ResultSet resultSet, final int index) throws SQLException {
    node.put(columnName, resultSet.getBigDecimal(index));
  }

  @Override
  public JsonNode rowToJson(ResultSet queryContext) throws SQLException {
    final int columnCount = queryContext.getMetaData().getColumnCount();
    final ObjectNode jsonNode = (ObjectNode) Jsons.jsonNode(Collections.emptyMap());

    for (int i = 1; i <= columnCount; i++) {
      try {
        queryContext.getObject(i);
        if (!queryContext.wasNull()) {
          setJsonField(queryContext, i, jsonNode);
        }
      } catch (SQLException e) {
        putCockroachSpecialDataType(queryContext, i, jsonNode);
      }
    }
    return jsonNode;
  }

  private void putCockroachSpecialDataType(ResultSet resultSet, int index, ObjectNode node) throws SQLException {
    String columnType = resultSet.getMetaData().getColumnTypeName(index);
    String columnName = resultSet.getMetaData().getColumnName(index);
    try {
      if ("numeric".equalsIgnoreCase(columnType)) {
        final double value = resultSet.getDouble(index);
        node.put(columnName, value);
      } else {
        node.put(columnName, (Double) null);
      }
    } catch (final SQLException e) {
      node.put(columnName, (Double) null);
    }
  }
}
