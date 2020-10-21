# generated by datamodel-codegen:
#   filename:  airbyte_message.yaml

from __future__ import annotations

from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import AnyUrl, BaseModel, Field


class Type(Enum):
    RECORD = 'RECORD'
    STATE = 'STATE'
    LOG = 'LOG'
    SPEC = 'SPEC'
    CONNECTION_STATUS = 'CONNECTION_STATUS'
    CATALOG = 'CATALOG'


class AirbyteRecordMessage(BaseModel):
    stream: str = Field(..., description='the name of the stream for this record')
    data: Dict[str, Any] = Field(..., description='the record data')
    emitted_at: int = Field(
        ...,
        description='when the data was emitted from the source. epoch in millisecond.',
    )


class AirbyteStateMessage(BaseModel):
    data: Dict[str, Any] = Field(..., description='the state data')


class Level(Enum):
    FATAL = 'FATAL'
    ERROR = 'ERROR'
    WARN = 'WARN'
    INFO = 'INFO'
    DEBUG = 'DEBUG'
    TRACE = 'TRACE'


class AirbyteLogMessage(BaseModel):
    level: Level = Field(..., description='the type of logging')
    message: str = Field(..., description='the log message')


class Status(Enum):
    SUCCEEDED = 'SUCCEEDED'
    FAILED = 'FAILED'


class AirbyteConnectionStatus(BaseModel):
    status: Status
    message: Optional[str] = None


class AirbyteStream(BaseModel):
    name: str = Field(..., description="Stream's name.")
    json_schema: Dict[str, Any] = Field(
        ..., description='Stream schema using Json Schema specs.'
    )


class ConnectorSpecification(BaseModel):
    documentationUrl: Optional[AnyUrl] = None
    changelogUrl: Optional[AnyUrl] = None
    connectionSpecification: Dict[str, Any] = Field(
        ...,
        description='ConnectorDefinition specific blob. Must be a valid JSON string.',
    )


class AirbyteCatalog(BaseModel):
    streams: List[AirbyteStream]


class AirbyteMessage(BaseModel):
    type: Type = Field(..., description='Message type')
    log: Optional[AirbyteLogMessage] = Field(
        None,
        description='log message: any kind of logging you want the platform to know about.',
    )
    spec: Optional[ConnectorSpecification] = None
    connectionStatus: Optional[AirbyteConnectionStatus] = None
    catalog: Optional[AirbyteCatalog] = Field(
        None,
        description='log message: any kind of logging you want the platform to know about.',
    )
    record: Optional[AirbyteRecordMessage] = Field(
        None, description='record message: the record'
    )
    state: Optional[AirbyteStateMessage] = Field(
        None,
        description='schema message: the state. Must be the last message produced. The platform uses this information',
    )
